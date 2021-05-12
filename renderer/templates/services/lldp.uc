
# LLDP service configuration

del lldp.config.interface
set lldp.config.description={{ s(lldp.describe) }}
set lldp.config.lldp_location={{ s(lldp.location) }}
