# secrets

System level:

```
sudo mkdir -p /var/lib/sops-nix/
sudo age-keygen -o /var/lib/sops-nix/key.txt
```

User level:

```
mkdir -p ~/.config/sops/age/
age-keygen -o ~/.config/sops/age/keys.txt
```
