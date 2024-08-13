# Install dos2unix
sudo apt install dos2unix

# Run the command to change CRLF Files to LF
find . -type f -exec dos2unix {} \;

# a Check the validity of the configuration file →
promtool check config /etc/prometheus/prometheus.yml

# b. Reload the Prometheus configuration without restarting →
curl -X POST http://localhost:9090/-/reload

sudo snap install helm --classic

terraform init -migrate-state
