"""Run on Windows for PowerShell 5.1, and Linux/macOS for bash. No Azure access."""
import json
import os
from pathlib import Path
import shlex
import subprocess
import sys
import tempfile
import unittest

HERE = Path(__file__).resolve().parent
SCRIPTS = HERE.parent / 'scripts'
PS = os.name == 'nt'
APPROVAL = '/subscriptions/target-sub/providers/Microsoft.Authorization/roleAssignmentApprovals/approval'
STAGE = APPROVAL + '/stages/stage'
ELIGIBLE = {'properties': {'expandedProperties': {'roleDefinition': {'displayName': 'Contributor'}},
                          'memberType': 'Direct', 'roleDefinitionId': '/subscriptions/target-sub/providers/Microsoft.Authorization/roleDefinitions/role',
                          'roleEligibilityScheduleId': '/subscriptions/target-sub/providers/Microsoft.Authorization/roleEligibilitySchedules/eligible',
                          'scope': '/subscriptions/target-sub/resourceGroups/allowed'}}


def resource(kind, properties, **extra):
    return {'id': '/subscriptions/target-sub/resourceGroups/rg/providers/' + kind + '/sample',
            'name': 'sample', 'type': kind, 'properties': properties, **extra}


class Scripts(unittest.TestCase):
    def run_script(self, kind, fixture, ps_args=None, sh_args=None):
        names = {'exposure': ('Get-AzPublicExposure.ps1', 'get-az-public-exposure.sh'),
                 'hardening': ('Set-AzNetworkAclHardening.ps1', 'set-az-network-acl-hardening.sh'),
                 'pim': ('Get-AzPimStatus.ps1', 'get-az-pim-status.sh'),
                 'rbac': ('Get-AzGroupRbacMap.ps1', 'get-az-group-rbac-map.sh')}
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            fixture_file, calls_file = root / 'fixture.json', root / 'calls.jsonl'
            fixture_file.write_text(json.dumps(fixture), encoding='utf-8')
            env = os.environ.copy()
            env.update(AUDIT_FIXTURE=str(fixture_file), AUDIT_CALLS=str(calls_file),
                       AUDIT_PYTHON=sys.executable, AUDIT_MOCK=str(HERE / 'mock_azure.py'))
            params = dict(ps_args or {})
            options = list(sh_args or [])
            if kind == 'hardening':
                (root / 'targets.json').write_text(json.dumps([{'Kind': fixture.get('kind', 'storage'), 'Sub': 'target-sub', 'Rg': 'rg', 'Name': 'same-name'}]), encoding='utf-8')
                (root / 'targets.tsv').write_text(f"{fixture.get('kind', 'storage')}\ttarget-sub\trg\tsame-name\n", encoding='utf-8')
                params['TargetJsonPath'] = str(root / 'targets.json')
                options.extend(['-f', str(root / 'targets.tsv')])
            if PS:
                (root / 'params.json').write_text(json.dumps(params), encoding='utf-8')
                env['AUDIT_SCRIPT'] = str(SCRIPTS / names[kind][0])
                env['AUDIT_PARAMS'] = str(root / 'params.json')
                wrapper = root / 'run.ps1'
                wrapper.write_text('''$ErrorActionPreference = 'Stop'
function global:az {
    & $env:AUDIT_PYTHON $env:AUDIT_MOCK @args
    $global:LASTEXITCODE = $LASTEXITCODE
}
function global:Invoke-RestMethod {
    param($Method = 'GET', $Uri, $Headers, $ContentType, $Body, $ErrorAction)
    $env:AUDIT_BODY = $Body
    $payload = & $env:AUDIT_PYTHON $env:AUDIT_MOCK --arm $Method $Uri
    if ($LASTEXITCODE -ne 0) { throw 'Mock ARM request failed' }
    $payload | ConvertFrom-Json
}
$params = @{}
(Get-Content $env:AUDIT_PARAMS -Raw | ConvertFrom-Json).PSObject.Properties | ForEach-Object { $params[$_.Name] = $_.Value }
& $env:AUDIT_SCRIPT @params
exit $LASTEXITCODE
''', encoding='utf-8')
                command = ['powershell', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', str(wrapper)]
            else:
                fake = root / 'az'
                fake.write_text('#!/bin/sh\nexec ' + shlex.quote(sys.executable) + ' ' + shlex.quote(str(HERE / 'mock_azure.py')) + ' "$@"\n', encoding='utf-8')
                fake.chmod(0o755)
                env['PATH'] = str(root) + os.pathsep + env['PATH']
                command = ['bash', str(SCRIPTS / names[kind][1]), *options]
            proc = subprocess.run(command, env=env, capture_output=True, text=True, timeout=60)
            calls = [json.loads(line) for line in calls_file.read_text(encoding='utf-8').splitlines()] if calls_file.exists() else []
            return proc.returncode, proc.stdout + proc.stderr, calls

    def exposure(self, item, **fixture):
        return self.run_script('exposure', {'resources': [item], **fixture}, {'SubscriptionId': ['target-sub'], 'IncludeCompliant': True}, ['-s', 'target-sub', '-a'])

    def test_inventory_failure_is_not_clean(self):
        rc, out, _ = self.run_script('exposure', {'failure': 'inventory'}, {'SubscriptionId': ['target-sub']}, ['-s', 'target-sub'])
        self.assertNotEqual(rc, 0, out)
        self.assertIn('unverifiable', out.lower())

    def test_direct_read_failure_is_visible(self):
        rc, out, _ = self.exposure(resource('Microsoft.KeyVault/vaults', {}), failure='read')
        self.assertNotEqual(rc, 0, out)
        self.assertIn('unverifiable', out.lower())

    def test_classic_cdn_does_not_query_frontdoor_waf(self):
        rc, out, calls = self.exposure(resource('Microsoft.Cdn/profiles', {}, sku={'name': 'Standard_Microsoft'}))
        self.assertNotEqual(rc, 0, out)
        self.assertIn('unsupported CDN SKU', out)
        self.assertFalse(any('/securityPolicies' in str(call) for call in calls))

    def test_waf_failure_is_unknown_not_zero(self):
        rc, out, _ = self.exposure(resource('Microsoft.Cdn/profiles', {}, sku={'name': 'Premium_AzureFrontDoor'}), failure='waf')
        self.assertNotEqual(rc, 0, out)
        self.assertIn('unverifiable', out.lower())
        self.assertNotIn('WAF policies: 0', out)

    def test_empty_frontdoor_policies_is_finding(self):
        rc, out, _ = self.exposure(resource('Microsoft.Cdn/profiles', {}, sku={'name': 'Standard_AzureFrontDoor'}))
        self.assertEqual(rc, 1, out)
        self.assertIn('FINDING', out)

    def test_nested_database_pna_and_private_aks(self):
        for kind, props in [('Microsoft.DBforPostgreSQL/flexibleServers', {'network': {'publicNetworkAccess': 'Disabled'}}),
                            ('Microsoft.DBforMySQL/flexibleServers', {'network': {'publicNetworkAccess': 'Disabled'}}),
                            ('Microsoft.ContainerService/managedClusters', {'apiServerAccessProfile': {'enablePrivateCluster': True}})]:
            with self.subTest(kind=kind):
                rc, out, _ = self.exposure(resource(kind, props))
                self.assertEqual(rc, 0, out)
                self.assertIn('ok', out)

    def test_missing_network_controls_are_unknown(self):
        rc, out, _ = self.exposure(resource('Microsoft.ContainerService/managedClusters', {'state': 'running'}))
        self.assertNotEqual(rc, 0, out)
        self.assertIn('unverifiable', out.lower())

    def test_sql_firewall_is_read(self):
        rc, out, calls = self.exposure(resource('Microsoft.Sql/servers', {'publicNetworkAccess': 'Enabled'}),
                                       firewall=[{'properties': {'startIpAddress': '0.0.0.0', 'endIpAddress': '255.255.255.255'}}])
        self.assertEqual(rc, 1, out)
        self.assertTrue(any('/firewallRules' in str(call) for call in calls))

    def test_network_rules_distinguish_filtered_access(self):
        for kind, props in [('Microsoft.ContainerRegistry/registries', {'publicNetworkAccess': 'Enabled', 'networkRuleSet': {'defaultAction': 'Deny'}}),
                            ('Microsoft.CognitiveServices/accounts', {'publicNetworkAccess': 'Enabled', 'networkAcls': {'defaultAction': 'Deny'}}),
                            ('Microsoft.DocumentDB/databaseAccounts', {'publicNetworkAccess': 'Enabled', 'ipRules': [], 'isVirtualNetworkFilterEnabled': False})]:
            with self.subTest(kind=kind):
                rc, out, _ = self.exposure(resource(kind, props))
                self.assertEqual(rc, 1 if kind.startswith('Microsoft.DocumentDB') else 0, out)

    def test_hardening_scopes_every_read_and_write(self):
        for kind in ['storage', 'keyvault']:
            with self.subTest(kind=kind):
                rc, out, calls = self.run_script('hardening', {'kind': kind}, {'Apply': True}, ['-A'])
                self.assertEqual(rc, 0, out)
                updates = [call for call in calls if 'update' in call]
                self.assertEqual(len(updates), 1, calls)
                for call in calls:
                    self.assertNotEqual(call[:2], ['account', 'set'])
                    if call[0] in ['storage', 'keyvault']:
                        self.assertEqual(call[call.index('--subscription') + 1], 'target-sub')

    def test_hardening_failed_read_never_updates(self):
        rc, out, calls = self.run_script('hardening', {'failure': 'hardening-read'}, {'Apply': True}, ['-A'])
        self.assertNotEqual(rc, 0, out)
        self.assertFalse(any('update' in call for call in calls))

    def approvals(self, **extra):
        fixture = {'approvals': [{'id': APPROVAL}], 'stages': [{'id': STAGE, 'properties': {'status': 'InProgress', 'assignedToMe': True}}], **extra}
        justification = 'Approve "quoted" \\ path\nnext\tline\x01'
        result = self.run_script('pim', fixture, {'SubscriptionId': 'target-sub', 'Approvals': True, 'Approve': True, 'Justification': justification}, ['-s', 'target-sub', '-L', '-P', '-j', justification])
        return justification, result

    def test_approval_uses_full_stage_id_and_encoded_json(self):
        justification, (rc, out, calls) = self.approvals()
        self.assertEqual(rc, 0, out)
        writes = [call for call in calls if 'PATCH' in call]
        self.assertEqual(len(writes), 1, out)
        call = writes[0]
        uri = call[2] if PS else call[call.index('--url') + 1]
        body = call[3] if PS else call[call.index('--body') + 1]
        self.assertEqual(uri.split('?')[0], 'https://management.azure.com' + STAGE)
        self.assertEqual(json.loads(body)['properties']['justification'], justification)

    def test_approval_failure_returns_nonzero(self):
        _, (rc, out, _) = self.approvals(failure='approve')
        self.assertNotEqual(rc, 0, out)

    def test_approval_list_failure_does_not_report_empty(self):
        _, (rc, out, _) = self.approvals(failure='approvals')
        self.assertNotEqual(rc, 0, out)
        self.assertNotIn('Nothing is awaiting', out)

    def test_activation_json_and_policy_duration(self):
        justification = 'Quote " and \\ and\nnewline'
        rc, out, calls = self.run_script('pim', {'eligible': [ELIGIBLE]},
                                        {'SubscriptionId': 'target-sub', 'Activate': True, 'Justification': justification, 'Hours': 4},
                                        ['-s', 'target-sub', '-A', '-j', justification, '-t', '4'])
        self.assertEqual(rc, 0, out)
        writes = [call for call in calls if 'PUT' in call]
        self.assertEqual(len(writes), 1, out)
        props = json.loads(writes[0][3] if PS else writes[0][writes[0].index('--body') + 1])['properties']
        self.assertEqual(props['justification'], justification)
        self.assertEqual(props['scheduleInfo']['expiration']['duration'], 'PT2H30M' if PS else 'PT4H')

    @unittest.skipIf(PS, 'PowerShell decodes the ARM token instead of using Graph')
    def test_failed_identity_lookup_prevents_activation(self):
        rc, out, calls = self.run_script('pim', {'eligible': [ELIGIBLE], 'failure': 'identity'}, sh_args=['-s', 'target-sub', '-A'])
        self.assertNotEqual(rc, 0, out)
        self.assertFalse(any('PUT' in call for call in calls))

    @unittest.skipUnless(PS, 'PowerShell preflights ticket policy; bash reports ARM validation failures')
    def test_required_ticket_is_not_fabricated(self):
        fixture = {'eligible': [ELIGIBLE], 'policy': [{'id': 'Enablement_EndUser_Assignment', 'enabledRules': ['Ticketing']}]}
        rc, out, calls = self.run_script('pim', fixture, {'SubscriptionId': 'target-sub', 'Activate': True})
        self.assertNotEqual(rc, 0, out)
        self.assertFalse(any('PUT' in call for call in calls))
        self.assertIn('TicketNumber', out)

    def test_rbac_query_failures_are_unknown(self):
        for failure in ['active', 'eligibility']:
            with self.subTest(failure=failure):
                rc, out, _ = self.run_script('rbac', {'failure': failure}, {'GroupId': ['group-id'], 'SubscriptionId': ['target-sub']}, ['-g', 'group-id', '-s', 'target-sub'])
                self.assertNotEqual(rc, 0, out)
                self.assertIn('UNVERIFIABLE', out)
                self.assertNotIn('[!]', out)

    def test_rbac_reports_assignment_scope_and_pagination(self):
        scope = '/subscriptions/target-sub/resourceGroups/unrelated'
        fixture = {'roles': [{'roleDefinitionName': 'Reader', 'scope': scope}], 'eligible_page2': [ELIGIBLE]}
        rc, out, _ = self.run_script('rbac', fixture, {'GroupId': ['group-id'], 'SubscriptionId': ['target-sub']}, ['-g', 'group-id', '-s', 'target-sub'])
        self.assertEqual(rc, 0, out)
        self.assertIn(scope, out)
        self.assertIn('/resourceGroups/allowed', out)


if __name__ == '__main__':
    unittest.main()
