$ORIGIN datacentric.dev.
$TTL 5
@	IN	SOA ns.datacentric.dev no-op.datacentric.dev. (
				1719463252 ; serial
				7200             ; refresh (2 hours), only affects secondary dns servers
				3600             ; retry (1 hour), only affects secondary dns servers
				604800           ; expire (1 week), only affects secondary dns servers
				5     ;
				)


masters IN A 10.10.0.86
masters IN A 10.10.0.195
masters IN A 10.10.0.19
workers IN A 10.10.0.132
workers IN A 10.10.0.13
workers IN A 10.10.0.92



