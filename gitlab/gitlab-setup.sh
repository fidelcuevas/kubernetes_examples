#!/bin/bash
microk8s.helm3 -n gitlab-system upgrade --install gitlab gitlab/gitlab \
  --timeout 600s \
  --set global.hosts.domain=sqis.io \
  --set global.hosts.externalIP=192.168.1.113 \
  --set global.hosts.ssh=gitlab-ssh.sqis.io \
  --set certmanager-issuer.email=fidel@sqis.io \
  --set gitlab.webservice.ingress.tls.secretName=gitlab-tls \
  --set global.kas.enabled=true
