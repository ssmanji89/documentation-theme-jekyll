# CVE-2022-28810 Detail

## Description

Zoho ManageEngine ADSelfService Plus before build 6122 allows a remote authenticated administrator to execute arbitrary operating OS commands as SYSTEM via the policy custom script feature. Due to the use of a default administrator password, attackers may be able to abuse this functionality with minimal effort. Additionally, a remote and partially authenticated attacker may be able to inject arbitrary commands into the custom script due to an unsanitized password field.

## Severity

- CVSS 3.x Severity and Metrics: 
  - NIST CVSS scoreNIST: NVDBase Score: 6.8 MEDIUM
  - Vector: CVSS:3.1/AV:N/AC:L/PR:H/UI:R/S:U/C:H/I:H/A:H

## Weakness Enumeration

- CWE-ID: CWE-78
- CWE Name: Improper Neutralization of Special Elements used in an OS Command ('OS Command Injection')
- Source: CWE Source Acceptance Level NIST

## References to Advisories, Solutions, and Tools

- http://packetstormsecurity.com/files/166816/ManageEngine-ADSelfService-Plus-Custom-Script-Execution.html
- https://github.com/rapid7/metasploit-framework/pull/16475
- https://www.manageengine.com/products/self-service-password/kb/cve-2022-28810.html
- https://www.rapid7.com/blog/post/2022/04/14/cve-2022-28810-manageengine-adselfservice-plus-authenticated-command-execution-fixed/

## Summary for Blog Post

Zoho ManageEngine ADSelfService Plus before build 6122 has been identified to have a vulnerability that allows remote authenticated administrators to execute arbitrary operating OS commands as SYSTEM via the policy custom script feature. An attacker may be able to abuse this functionality with minimal effort due to the use of a default administrator password. Additionally, a remote and partially authenticated attacker may be able to inject arbitrary commands into the custom script due to an unsanitized password field. This vulnerability has been assigned CVE-2022-28810, and it has a CVSS 3.x score of 6.8. Organizations that use Zoho ManageEngine ADSelfService Plus should apply updates per vendor instructions to remediate this vulnerability.
