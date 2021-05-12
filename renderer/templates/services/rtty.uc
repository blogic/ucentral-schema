
# RTTY service configuration

set rtty.@rtty[-1].enable={{ b((rtty.token && rtty.host && rtty.port)) }}
set rtty.@rtty[-1].token={{ s(rtty.token) }}
set rtty.@rtty[-1].host={{ s(rtty.host) }}
set rtty.@rtty[-1].host={{ s(rtty.port) }}
