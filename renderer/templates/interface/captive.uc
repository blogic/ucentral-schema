
# Captive Portal Configuration
add opennds opennds
set opennds.@opennds[-1].enabled='1'
set opennds.@opennds[-1].fwhook_enabled='1'
set opennds.@opennds[-1].debuglevel='1'
add_list opennds.@opennds[-1].users_to_router='allow tcp port 53'
add_list opennds.@opennds[-1].users_to_router='allow udp port 53'
add_list opennds.@opennds[-1].users_to_router='allow udp port 67'
add_list opennds.@opennds[-1].users_to_router='allow tcp port 22'
add_list opennds.@opennds[-1].users_to_router='allow tcp port 80'
add_list opennds.@opennds[-1].users_to_router='allow tcp port 443'
add_list opennds.@opennds[-1].authenticated_users='allow all'
set opennds.@opennds[-1].login_option_enabled='1'
set opennds.@opennds[-1].gatewayinterface='br-captive'
set opennds.@opennds[-1].gatewayname={{ s(interface.captive.gateway_name) }}
set opennds.@opennds[-1].maxclients='{{ interface.captive.max_clients }}'
set opennds.@opennds[-1].gatewayfqdn={{ s(interface.captive.gateway_fqdn) }}
set opennds.@opennds[-1].uploadrate='{{ interface.captive.upload_rate }}'
set opennds.@opennds[-1].downloadrate='{{ interface.captive.download_rate }}'
set opennds.@opennds[-1].uploadquota='{{ interface.captive.upload_quota }}'
set opennds.@opennds[-1].downloadquota='{{ interface.captive.download_quota }}'
