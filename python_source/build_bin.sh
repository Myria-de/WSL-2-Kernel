cd $HOME/.deploy-windows/deploy-win
$HOME/.deploy-windows/bin/pyinstaller --python-option u  --hidden-import ntfs_acl --add-binary BCD:. --add-binary BCD-efi:. --onefile  --console setup_win10.py
