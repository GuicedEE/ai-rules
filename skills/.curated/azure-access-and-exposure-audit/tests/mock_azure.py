#!/usr/bin/env python3
"""Offline Azure CLI/ARM fixture transport; never falls through to real Azure."""
import base64
import json
import os
import sys
from urllib.parse import parse_qs, urlsplit

import jmespath


def main():
    args = sys.argv[1:]
    if args[0] == '--arm':
        args = args[:3] + [os.environ.get('AUDIT_BODY', '')]
    with open(os.environ['AUDIT_FIXTURE'], encoding='utf-8') as stream:
        fixture = json.load(stream)
    with open(os.environ['AUDIT_CALLS'], 'a', encoding='utf-8') as stream:
        stream.write(json.dumps(args) + '\n')

    def option(name, default=None):
        return args[args.index(name) + 1] if name in args else default

    def fail(kind):
        if fixture.get('failure') == kind:
            raise RuntimeError('Fixture failure: ' + kind)

    def arm(method, uri, body):
        path = urlsplit(uri).path
        query = parse_qs(urlsplit(uri).query)
        if method.upper() in ('PATCH', 'PUT'):
            props = json.loads(body)['properties']
            if method.upper() == 'PUT':
                deactivate = props['requestType'] == 'SelfDeactivate'
                selected = fixture['active' if deactivate else 'eligible'][0]['properties']
                expected = selected['scope'] + '/providers/Microsoft.Authorization/roleAssignmentScheduleRequests/'
                if not path.startswith(expected):
                    raise RuntimeError('Request did not use the selected assignment scope')
                if deactivate:
                    if props.get('targetRoleAssignmentScheduleId') != selected['roleAssignmentScheduleId']:
                        raise RuntimeError('Deactivation did not target the active schedule')
                    if any(key in props for key in ['linkedRoleAssignmentScheduleId', 'linkedRoleEligibilityScheduleId', 'scheduleInfo']):
                        raise RuntimeError('Invalid deactivation body')
            fail('approve' if method.upper() == 'PATCH' else 'activate')
            return {'properties': {'status': 'Provisioned'}}
        if path.endswith('/resources'):
            fail('inventory')
            resource_type = query['$filter'][0].split("'")[1]
            if fixture.get('inventory_failure_type') == resource_type:
                raise RuntimeError('Fixture inventory failure for ' + resource_type)
            return {'value': [r for r in fixture.get('resources', []) if r['type'] == resource_type]}
        if path.endswith('/securityPolicies'):
            fail('waf')
            return {'value': fixture.get('policies', [])}
        if path.endswith('/slots'):
            fail('slots')
            return {'value': fixture.get('slots', [])}
        if path.endswith('/firewallRules'):
            fail('firewall')
            return {'value': fixture.get('firewall', [])}
        if path.endswith('/roleAssignmentApprovals'):
            fail('approvals')
            return {'value': fixture.get('approvals', [])}
        if path.endswith('/stages'):
            fail('stages')
            return {'value': fixture.get('stages', [])}
        if path.endswith('/roleEligibilityScheduleInstances'):
            fail('eligibility')
            if fixture.get('eligible_page2') and query.get('page') != ['2']:
                return {'value': fixture.get('eligible', []), 'nextLink': uri + '&page=2'}
            return {'value': fixture.get('eligible_page2', fixture.get('eligible', []))}
        if path.endswith('/roleAssignmentScheduleInstances'):
            fail('active')
            return {'value': fixture.get('active', [])}
        if path.endswith('/roleAssignmentScheduleRequests'):
            fail('requests')
            return {'value': []}
        if path.endswith('/roleManagementPolicyAssignments'):
            fail('policy')
            return {'value': [{'properties': {'policyId': '/providers/Microsoft.Authorization/roleManagementPolicies/policy'}}]}
        if path.endswith('/roleManagementPolicies/policy'):
            fail('policy')
            return {'properties': {'rules': fixture.get('policy', [
                {'id': 'Expiration_EndUser_Assignment', 'maximumDuration': 'PT2H30M'}
            ])}}
        fail('read')
        for resource in fixture.get('resources', []):
            if path == resource['id']:
                return resource
        raise RuntimeError('Unexpected ARM read: ' + uri)

    transport = args[0] == '--arm'
    if transport:
        data = arm(args[1], args[2], args[3] if len(args) > 3 else '')
    elif args[:2] == ['account', 'show']:
        data = {'id': 'target-sub', 'name': 'Target', 'user': {'name': 'fixture-user'}}
    elif args[:2] == ['account', 'set']:
        raise RuntimeError('Scripts must not change the active subscription')
    elif args[:2] == ['account', 'get-access-token']:
        fail('token')
        payload = base64.urlsafe_b64encode(json.dumps({'oid': 'fixture-user-id'}).encode()).decode().rstrip('=')
        data = {'accessToken': 'header.' + payload + '.signature'}
    elif args[:2] == ['resource', 'list']:
        fail('inventory')
        if fixture.get('inventory_failure_type') == option('--resource-type'):
            raise RuntimeError('Fixture inventory failure for ' + option('--resource-type'))
        data = [r for r in fixture.get('resources', []) if r['type'] == option('--resource-type')]
    elif args[:2] == ['resource', 'show']:
        data = arm('GET', 'https://management.azure.com' + option('--ids'), '')
    elif args[0] == 'rest':
        data = arm(option('--method'), option('--url'), option('--body', ''))
    elif args[:3] == ['ad', 'signed-in-user', 'show']:
        fail('identity')
        data = {'id': fixture.get('oid', 'fixture-user-id')}
    elif args[:3] == ['ad', 'group', 'show']:
        data = {'displayName': 'Fixture Group'}
    elif args[:3] == ['ad', 'group', 'list']:
        data = [{'id': 'group-id', 'displayName': 'Fixture Group'}]
    elif args[:4] == ['ad', 'group', 'member', 'list']:
        fail('members')
        data = fixture.get('members', [])
    elif args[:3] == ['role', 'assignment', 'list']:
        fail('active')
        data = fixture.get('roles', [])
    elif args[:2] == ['storage', 'account'] or args[0] == 'keyvault':
        if option('--subscription') != 'target-sub':
            raise RuntimeError('Unscoped or wrong-subscription hardening command')
        fail('hardening-read' if 'show' in args else 'hardening-write')
        data = {'publicNetworkAccess': 'Disabled', 'networkRuleSet': {'defaultAction': 'Allow', 'bypass': 'None'},
                'properties': {'publicNetworkAccess': 'Disabled', 'networkAcls': {'defaultAction': 'Allow', 'bypass': 'None'}}}
    else:
        raise RuntimeError('Unexpected CLI invocation: ' + repr(args))

    query = option('--query') if not transport else None
    if query:
        data = jmespath.search(query, data)
    output = option('-o', 'json') if not transport else 'json'
    if output == 'none':
        return
    if output == 'json':
        print(json.dumps(data))
    elif data is not None:
        def cell(value):
            if value is None:
                return 'None'
            return str(value)
        rows = data if isinstance(data, list) else [data]
        for row in rows:
            print('\t'.join(cell(value) for value in row) if isinstance(row, list) else cell(row))


if __name__ == '__main__':
    try:
        main()
    except Exception as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
