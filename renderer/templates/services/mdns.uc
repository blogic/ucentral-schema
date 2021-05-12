
# MDNS service configuration

delete umdns.@umdns[-1].network
set umdns.@umdns[-1].enable={{ b(mdns.enable) }}
