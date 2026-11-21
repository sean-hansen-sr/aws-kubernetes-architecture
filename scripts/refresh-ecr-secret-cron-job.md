**Create the Refresh Script**  
`cat << EOF > refresh-ecr-secret.sh`  
`!/bin/bash`  
`set -e`  

`# Ensure standard paths are available for cron`  
`export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin`  

`# Explicitly set KUBECONFIG for root cron environment`  
`export KUBECONFIG=/etc/kubernetes/admin.conf`  

`echo "[$(date -u '+%Y-%m-%d %H:%M:%S UTC')] Starting ECR secret refresh..."`  

`ECR_PASSWORD=$(aws ecr get-login-password --region us-east-1)`  
`if [ -z "$ECR_PASSWORD" ]; then`  
`  echo "[$(date -u '+%Y-%m-%d %H:%M:%S UTC')] ERROR: Failed to retrieve ECR password" >&2`  
`  exit 1`  
`fi`  

`kubectl create secret docker-registry ecr-registry-secret \`  
`  --docker-server=://amazonaws.com \`  
`  --docker-username=AWS \`  
`  --docker-password="${ECR_PASSWORD}" \`  
`  --namespace=default \`  
`  --dry-run=client -o yaml | kubectl apply -f -`  

`echo "[$(date -u '+%Y-%m-%d %H:%M:%S UTC')] ECR secret refreshed successfully."`  
`EOF`  

**Move the script to /usr/local/bin**  
sudo mv refresh-ecr-secret.sh /usr/local/bin/  

**Make it executable**  
sudo chmod +x /usr/local/bin/refresh-ecr-secret.sh  

**Add the Cron Job**  
sudo crontab -e  

**Add the following line to end**  
`0 */4 * * * /usr/local/bin/refresh-ecr-secret.sh >> /var/log/ecr-refresh.log 2>&1`  

**Set up log file permissions**  
sudo touch /var/log/ecr-refresh.log  
`sudo chown $USER:$USER /var/log/ecr-refresh.log`  

**Set up logrotate for /var/log/ecr-refresh.log so it doesn't grow indefinitely**  
`sudo tee /etc/logrotate.d/ecr-refresh > /dev/null <<'EOF'`  
`/var/log/ecr-refresh.log {`  
`    su root syslog`  
`    weekly`  
`    rotate 4`  
`    compress`  
`    delaycompress`  
`    missingok`  
`    notifempty`  
`    copytruncate`  
`}`  
`EOF`  

**Test the configuration**. 
sudo logrotate -d /etc/logrotate.d/ecr-refresh  

**Run with debug mode to verify**  
sudo /usr/local/bin/refresh-ecr-secret.sh && cat /var/log/ecr-refresh.log
