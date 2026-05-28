images:
.PHONY: images
	-docker rmi -f host_abait-ta:abait-ta || true
	-docker rmi -f router_abait-ta:abait-ta || true
	docker build -t host_abait-ta:abait-ta -f dockerfile.host .
	docker build -t router_abait-ta:abait-ta -f dockerfile.router .
