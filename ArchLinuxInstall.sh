# Live CD

## 验证引导模式
### 要验证引导模式，请用下列命令列出 efivars 目录：
ls /sys/firmware/efi/efivars
###     如果命令结果显示了目录且没有报告错误，则系统以 UEFI 模式引导。 
###     如果目录不存在，则系统可能以 BIOS 模式 (或 CSM 模式) 引导。如果系统未以您想要的模式引导启动，请参考您的主板说明书。

## 连接到互联网
### 确保系统已经启用了网络接口，用 ip-link 检查：
ip link
### 用 ping 检查网络连接：
ping archlinux.org

## 更新系统时间
### 在 Live 环境中 systemd-timesyncd 默认启用，建立互联网连接后，时间将自动同步。
###     使用 timedatectl 确保系统时间是准确的：
timedatectl status

## 建立硬盘分区
### 可以使用 lsblk 或者 fdisk 查看
###     结果中以 rom、loop 或者 airoot 结尾的设备可以被忽略。
fdisk -l
### 请使用 fdisk 或 parted 修改分区表
###     分区示例：https://wiki.archlinuxcn.org/wiki/%E5%AE%89%E8%A3%85%E6%8C%87%E5%8D%97#%E5%88%86%E5%8C%BA%E7%A4%BA%E4%BE%8B
fdisk /dev/sda

## 格式化分区
### 在根分区 /dev/root_partition 上创建一个 Ext4 文件系统
mkfs.ext4 /dev/sda2
### 如果创建了交换分区，请使用 mkswap 将其初始化
mkswap /dev/sda1

## 挂载分区
### 将根磁盘卷挂载到 /mnt
mount /dev/sda2 /mnt
### 然后使用 mkdir 创建其他剩余的挂载点（比如 /mnt/efi）并挂载其相应的磁盘卷。
###     提示： 使用 --mkdir 选项运行 mount 来创建指定的挂载点。或者，先使用 mkdir 创建挂载点再挂载。
###     注意： 挂载分区一定要遵循顺序，先挂载根（root）分区（到 /mnt），
###     再挂载引导（boot）分区（到 /mnt/boot 或 /mnt/efi，如果单独分出来了的话），最后再挂载其他分区。
###     否则您可能遇到安装完成后无法启动系统的问题
mount /dev/sda3 /mnt/home	
### 如果创建了交换空间卷，请使用 swapon 启用它：
swapon /dev/sda1

## 安装
### 选择镜像
###     文件 /etc/pacman.d/mirrorlist 定义了软件包会从哪个镜像下载。
###     在列表中越前的镜像在下载软件包时有越高的优先权。
###     可以相应的修改 /etc/pacman.d/mirrorlist 文件，并将地理位置最近的镜像源挪到文件的头部，同时也应该考虑一些其他标准。
###     这个文件接下来还会被 pacstrap 拷贝到新系统里，所以请确保设置正确。
vim /etc/pacman.d/mirrorlist
### 安装必需的软件包
###     使用 pacstrap 脚本，安装 base包 软件包和 Linux 内核以及常规硬件的固件：
pacstrap -K /mnt base linux linux-firmware

## 配置系统
### Fstab
###     用以下命令生成 fstab 文件 (用 -U 或 -L 选项设置 UUID 或卷标)
genfstab -U /mnt >> /mnt/etc/fstab
###     强烈建议在执行完以上命令后，检查一下生成的 /mnt/etc/fstab 文件是否正确。

## Chroot
### chroot 到新安装的系统：
arch-chroot /mnt


# arch-chroot

## 时区
### 要设置时区：
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
### 然后运行 hwclock 以生成 /etc/adjtime
hwclock --systohc

## 本地化
### 编辑 /etc/locale.gen，然后取消掉 en_US.UTF-8 UTF-8 和其他需要的区域设置前的注释（#）
pacman -Sy
pacman -S vim
vim /etc/locale.gen 
### 接着执行 locale-gen 以生成 locale 信息
locale-gen
### 然后创建 locale.conf 文件，并 编辑设定 LANG 变量，比如：
###     LANG=en_US.UTF-8
###     另外对于中文用户：
###     将系统 locale 设置为 en_US.UTF-8 ，系统的 log 就会用英文显示，这样更容易判断和处理问题；
###     设置的 LANG 变量需与 locale 设置一致，否则会出现以下错误：
###         Cannot set LC_CTYPE to default locale: No such file or directory
###     警告： 不推荐在此设置任何中文 locale，会导致 tty 上中文显示为方块
##### echo 'LANG=en_US.UTF-8' > /etc/locale.conf
vim /etc/locale.conf

## 网络配置
### 创建 hostname 文件
###     myhostname（主机名）
vim /etc/hostname
### 列出网络接口
ip link
### 可以使用 ip link set interface up|down 来启用/禁用网络接口
ip link set enp0s3 up
### 要想检查接口的状态：
ip link show dev enp0s3
### 列出 IP 地址：
ip address show
### 在等待分配 IP 时，可以运行 watch -n 1 ping -c 1 archlinux.org 之类的命令来自动确认网络是否配置好。
##### watch -n 1 ping -c 1 archlinux.org
### 要使用 DHCP ，需要网络中有 DHCP 服务器和 DHCP 客户端
###     客户端：dhcpcd；软件包：dhcpcd
###     安装 软件包 dhcpcd
pacman -S dhcpcd
### 要为 全部 网络接口提供服务，start/enable dhcpcd.service
systemctl enable dhcpcd
dhcpcd

## Root 密码
passwd

## 安装引导程序
##  警告： 这是安装的最后一步也是至关重要的一步，请按上述指引正确安装好引导加载程序后再重新启动。否则重启后将无法正常进入系统。
##  GRUB
##  BIOS 系统
### 安装 软件包 grub
pacman -S grub
### 注意这里的i386-pc是有意为之，与你机器的实际架构无关
grub-install --target=i386-pc /dev/sda
### 使用 grub-mkconfig 工具来生成 /boot/grub/grub.cfg
grub-mkconfig -o /boot/grub/grub.cfg

## 重启
### 输入 exit 或按 Ctrl+d 退出 chroot 环境
###     可选用 umount -R /mnt 手动卸载被挂载的分区：这有助于发现任何“繁忙”的分区，并通过 fuser 查找原因。
exit
### 最后，通过执行 reboot 重启系统，systemd 将自动卸载仍然挂载的任何分区。不要忘记移除安装介质，然后使用 root 帐户登录到新系统。
reboot


# 安装后的工作

## 添加登录用户
### 此命令会自动创建 archie 群组，并成为 archie 的默认登录群组。建议每一个用户都设置自己的默认群组，因为umask 默认值是 002, 所以同一个默认群组的用户会有创建文件的写权限
useradd -m lmliang
### 通过下列命令设置用户密码，虽然不是必须的，还是强烈建议设置密码
passwd lmliang

## 权限提升
### 安装 sudo 软件包。
pacman -S sudo
### sudo的配置文件是/etc/sudoers。visudo会锁住sudoers文件，保存修改到临时文件，然后检查文件格式，
###     确保正确后才会覆盖sudoers文件。必须保证sudoers格式正确，否则sudo将无法运行。
###     警告： /etc/sudoers格式错误会导致sudo不可用。必须使用visudo编辑该文件防止出错。
###     要为某个用户可以执行所有命令，在配置文件中加入：
###     用户名   ALL=(ALL) ALL
pacman -S vi
visudo 
exit

## 显示服务
### 安装 软件包 xorg-server。
sudo pacman -S xorg-server

## 桌面环境
##  KDE
### 安装 plasma-meta 元软件包或者 plasma 组
sudo pacman -S plasma-meta
### 若要安装 KDE 的全套应用，请安装 kde-applications 组或 kde-applications-meta 元软件包
sudo pacman -S kde-applications
### 若要使用 "xinit/startx" 启动 Plasma 桌面，请在 .xinitrc 文件中添加 
###     export DESKTOP_SESSION=plasma 和 exec startplasma-x11。
vim .xinitrc
### 安装 xorg-xinit 包
sudo pacman -S xorg-xinit
### 要以普通用户身份运行 Xorg，请输入：
startx

## 中文显示
sudo pacman -S noto-fonts
vim .config/plasma-localerc 
sudo pacman -S noto-fonts-cjk

## 中文输入法
##  常用的中文输入法平台有 IBus、fcitx、fcitx5 和 scim。具体安装配置参见各自条目。
### 安装软件包 fcitx（包）
sudo pacman -S fcitx
### fcitx-googlepinyin包, Google 拼音输入法
sudo pacman -S fcitx-googlepinyin
### 当您安装好 Fcitx 并重新登录后，Fcitx 应该会自动启动。如果没有的话，可以打开控制台并运行fcitx
fcitx
### Fcitx 提供了若干图形界面的配置程序：KDE 中的 kcm-fcitx包, 基于 GTK+3 的 fcitx-configtool包
sudo pacman -S kcm-fcitx
sudo pacman -S fcitx-configtool
### 安装完配置工具fcitx-configtool包之后打开配置工具的方法是用终端运行fcitx-config-gtk3，
###     打开这个配置工具之后还要添加中文输入法。对于新安装的英文系统，要取消只显示当前语言的输入法
###     （Only Show Current Language），才能看到和添加中文输入法(Pinyin, Libpinyin等)
fcitx-config-gtk3
### 设置输入法的环境变量
###     请按以下方式设置环境变量，如果没有这些环境变量，程序可能默认使用 XIM 协议。
###     qt5 程序不支持 XIM 所以必须配置使用 IM 模块，其它程序也有可能出现问题。
###     建议通过 /etc/environment 设置环境变量，pam-env 模块会在所有登录会话中读取此文件，
###     包括 X11 会话和 Wayland 会话。详情请参考 man 8 pam-env。
###     GTK_IM_MODULE=fcitx
###     QT_IM_MODULE=fcitx
###     XMODIFIERS=@im=fcitx
###     部分登录管理器（如 LightDM）也支持读取 ~/.xprofile，可以这样设置：
###     export GTK_IM_MODULE=fcitx
###     export QT_IM_MODULE=fcitx
###     export XMODIFIERS=@im=fcitx
##### echo 'export GTK_IM_MODULE=fcitx
##### export QT_IM_MODULE=fcitx
##### export XMODIFIERS=@im=fcitx' >> ~/.xprofile
vim .xprofile
### 如果 fcitx 没有自动启动，请将 fcitx & 加入 ~/.xinitrc, 如果 fcitx & 不启动，在后面加一个延时 sleep 2
###     例：
###     export DESKTOP_SESSION=plasma
###     exec fcitx &
###             sleep 2
###             startplasma-x11
vim .xinitrc 
### 问题检测
##### fcitx-diagnose


# 开发环境

## 终端
sudo pacman -S konsole

## Git
pacman -S git

## Node
sudo pacman -S nodejs

## Chrome
cd;
mkdir AUR; cd AUR
git clone https://aur.archlinux.org/google-chrome.git
cd google-chrome
makepkg -s
##### pacman -U google-chrome-108.0.5359.124-1-x86_64.pkg.tar.zst

## VSCode
cd ~/AUR
git clone https://aur.archlinux.org/visual-studio-code-bin.git
cd visual-studio-code-bin
makepkg -s
##### pacman -U visual-studio-code-bin-1.74.2-1-x86_64.pkg.tar.zst