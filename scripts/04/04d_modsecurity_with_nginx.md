# install necessary ModSecurity module for existing apache2 installation
echo "load_module modules/ngx_http_modsecurity_module.so;" >>/etc/nginx/nginx.conf
cp /etc/nginx/modsec/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.con
sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/nginx/modsec/modsecurity.conf
cat >> /etc/nginx/modsec/main.conf <!
# Include the recommended configuration
Include /etc/nginx/modsec/modsecurity.conf
# OWASP CRS v3 rules
#Include /usr/local/owasp-modsecurity-crs-3.0.2/crs-setup.conf
# etc.
#Include /usr/local/owasp-modsecurity-crs-3.0.2/rules/REQUEST-912-DOS-PROTECTION.conf
#Include /usr/local/owasp-modsecurity-crs-3.0.2/rules/REQUEST-913-SCANNER-DETECTION.conf
!

# optionally download a prepared nginx with ModSecurity from
# https://github.com/owasp-modsecurity/ModSecurity-nginx