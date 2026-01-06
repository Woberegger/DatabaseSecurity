# DBSec04 - modsecurity with nginx

**TODO:**
install necessary ModSecurity module for existing nginx installation
see howto e.g. under [](https://www.linode.com/docs/guides/securing-nginx-with-modsecurity/)

modify nginx configuration to load modsecurity module
```bash
echo "load_module modules/ngx_http_modsecurity_module.so;" >>/etc/nginx/nginx.conf
cp /etc/nginx/modsec/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf
sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/nginx/modsec/modsecurity.conf
```

and adapt the main config file for modsec module
```bash
cat >> /etc/nginx/modsec/main.conf <!
# Include the recommended configuration
Include /etc/nginx/modsec/modsecurity.conf
# OWASP CRS v3 rules
#Include /usr/local/owasp-modsecurity-crs-3.0.2/crs-setup.conf
# etc.
#Include /usr/local/owasp-modsecurity-crs-3.0.2/rules/REQUEST-912-DOS-PROTECTION.conf
#Include /usr/local/owasp-modsecurity-crs-3.0.2/rules/REQUEST-913-SCANNER-DETECTION.conf
!
```

optionally download a prepared nginx with ModSecurity from link
[](https://github.com/owasp-modsecurity/ModSecurity-nginx)