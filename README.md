[![Sponsors](https://img.shields.io/github/sponsors/QuackHack-McBlindy?logo=githubsponsors&label=Sponsor&style=flat&labelColor=ff1493&logoColor=fff&color=rgba(234,74,170,0.5) "")](https://github.com/sponsors/QuackHack-McBlindy) [![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-Sponsor?style=flat&logo=buymeacoffee&logoColor=fff&labelColor=ff1493&color=ff1493)](https://buymeacoffee.com/quackhackmcblindy)

# **nix-caddy-duckdns**

This flake builds Caddy package with the DuckDNS plugin.  
Also includes a service to syncronize your DuckDNS domains with your IP.  

```nix
{
  services.duckdns = {
    enable = true;
    # domains = [ "mydomain1" mydomain2" "mydomain3" ];
    # or (comma seperated)
    domainsFile = "/run/secrets/duckdns-domains";
    tokenFile = "/run/secrets/duckdns-token";
  };
}
```



