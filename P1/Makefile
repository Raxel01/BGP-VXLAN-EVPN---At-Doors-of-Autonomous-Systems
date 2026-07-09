images:
	-docker rmi -f host_abait-ta:abait-ta  alpine-host  bgp-host  || true
	-docker rmi -f router_abait-ta:abait-ta  alpine-frr  bgp-router || true
	docker build -t host_abait-ta:abait-ta  -t alpine-host -t bgp-host   -f dockerfile.host .
	docker build -t router_abait-ta:abait-ta -t alpine-frr -t bgp-router -f dockerfile.router .
