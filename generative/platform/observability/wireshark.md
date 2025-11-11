# Wireshark — Diagnostics Guide

Use this guide when you need to capture and analyze network traffic to troubleshoot connectivity, protocol behavior, performance, or security issues across services (backend, frontend, databases, external APIs).

Audience: developers, SREs, QA, and network engineers.

---

## When to use Wireshark
- Intermittent timeouts, resets, TLS handshake failures
- gRPC/HTTP/2 framing or header issues
- WebSocket connectivity or message ordering issues
- DNS, TCP three-way handshake, retransmissions, or MTU/fragmentation problems
- Verifying mTLS, ciphers, and certificate details
- Correlating application logs with network-level truth

---

## Install and capture basics
- Download: https://www.wireshark.org/
- Privileges: capturing on some interfaces requires admin rights.
- Interfaces:
  - Localhost/loopback: use the "Npcap Loopback Adapter" on Windows; on Linux/macOS, use lo/lo0.
  - Remote servers/containers: prefer remote capture (ssh + tcpdump) then open the pcap in Wireshark.
- Start/Stop: use the blue shark fin to start, red square to stop. Limit capture duration/size.

Tip: Use ring buffers or capture filters to avoid massive files in high-traffic environments.

---

## Capture vs Display filters
- Capture filters (BPF syntax) limit what gets recorded. Set before starting capture.
  - Examples:
    - host 10.0.0.5
    - port 443
    - tcp and (port 443 or port 80)
    - net 10.0.0.0/8
- Display filters (Wireshark syntax) show subsets of captured packets. Apply after capture.
  - Examples:
    - ip.addr == 10.0.0.5
    - tcp.port == 443
    - http || http2 || grpc
    - tls.handshake.type == 1  (ClientHello)
    - tcp.analysis.retransmission

Reference: Help → Supported Filter Syntax or https://www.wireshark.org/docs/

---

## Common workflows

### 1) TLS/HTTPS troubleshooting
- Filter: tls || ssl || tcp.port == 443
- Check: Server Name Indication (tls.handshake.extensions_server_name), protocol versions, cipher suites
- Validate certificate chain and expiration; confirm mTLS (CertificateRequest, client certificate present)
- Use "Follow TLS Stream" for decrypted payloads only if keys are available

Decrypting TLS (when permissible):
- Option A (Browser): set SSLKEYLOGFILE env var; configure Wireshark to use the generated key log file (Preferences → Protocols → TLS → (Pre)-Master-Secret log filename)
- Option B (Server): load static RSA keys (rare with modern TLS 1.3); not typical
- Ensure you have legal authority and approvals before decrypting

### 2) HTTP/2 and gRPC
- Filter: http2 || grpc
- Inspect streams: right-click → Follow → HTTP/2 Stream
- Look for RESET_STREAM, flow control windows, header compression (HPACK) anomalies
- gRPC status codes appear at end of streams; verify content-type application/grpc

### 3) WebSockets
- Filter: http.websocket || websocket
- Check the HTTP 101 Switching Protocols handshake
- Use "Follow → TCP Stream" to see message ordering; verify masking and fragmentation

### 4) TCP connectivity and performance
- Filter: tcp && (ip.addr == <host> || tcp.port == <port>)
- Use "Statistics → Conversations" and "I/O Graphs" to view throughput and RTT
- Look for SYN/SYN-ACK/ACK, zero windows, retransmissions, DUP ACKs, out-of-order segments
- MSS/MTU issues: find ICMP Fragmentation Needed messages

### 5) DNS
- Filter: dns
- Validate A/AAAA/CNAME responses, TTLs, and NXDOMAINs; check EDNS and truncation (TC bit)

---

## Performance and limits
- Prefer short, targeted captures with filters; rotate files for long sessions
- On servers: capture with tcpdump (ring buffer), then analyze locally
  - Example: sudo tcpdump -i eth0 -w out-%Y%m%d%H%M%S.pcap -G 60 -W 10 'tcp port 443'
- Use sample/summary views: Statistics → Protocol Hierarchy, Endpoints, and Expert Information

---

## Privacy, security, and legal
- Never capture traffic you are not authorized to inspect
- Avoid storing PII/credentials; scrub or encrypt captures at rest
- Use decryption only with explicit approval; adhere to company security policies and local laws
- Share pcaps via secured channels; time-bound retention

---

## Collaboration tips
- Correlate timestamps with application logs; synchronize clocks (NTP)
- Attach capture settings and filters when sharing a pcap
- Include environment notes: interface, client/server IPs, ports, and reproduction steps

---

## See also
- Observability index — ./README.md
- Platform category index — ../README.md
- Env variables reference — ../secrets-config/env-variables.md
