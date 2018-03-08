# zabbix-template-openhardwaremonitor
A Zabbix Template and UserParameter scripts to get sensor information from OpenHardwareMonintor via WMI.

## Installation

 - Copy the contents of `/bin` to the location your Zabbix Agent will be reading UserParameter scripts from.
 - Import the template in `/template` to your Zabbix Server instance, and assign it to a host running OpenHardwareMonitor that has WMI accessible.

## Support

 - None. I will not help you troubleshoot WMI. I had issues with WMI, which required me to update OpenHardwareMonitor to v0.8.0.3, however that may just have been a case of Error: ID10T.
