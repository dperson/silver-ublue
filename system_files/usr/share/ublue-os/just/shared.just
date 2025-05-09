# vim: set ft=make :
# These are recipes that are generic and should be available in bluefin and aurora

# Toggle LUKS auto-unlock via TPM2
[group('System')]
toggle-tpm2:
    @/usr/libexec/luks-tpm2-autounlock

# Factory reset this device (experimental)
[group('System')]
powerwash:
    #!/usr/bin/env -S bash
    text='Warning: This is an experimental feature that will reset this device '
    text+='to its factory state.'
    FIRST_CONFIRMATION=$(gum choose --header="$text" "No" \
          "Yes - wipe this machine")
    if [[ "$FIRST_CONFIRMATION" != "Yes - wipe this machine" ]]; then
      echo "Powerwash cancelled."
      exit 0
    fi
    SECOND_CONFIRMATION=$(gum choose --header="Are you sure?" "No" \
          "Yes - wipe this machine")
    if [[ "$SECOND_CONFIRMATION" != "Yes - wipe this machine" ]]; then
      echo "Powerwash cancelled."
      exit 0
    fi
    sudo bootc install reset --experimental