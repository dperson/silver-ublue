# vim: set ft=make :
# These are recipes that are generic and should be available in bluefin and aurora

# Enable automatic LUKS unlock via TPM
[group('System')]
toggle-tpm2:
    @/usr/libexec/luks-tpm2-autounlock