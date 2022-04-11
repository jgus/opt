FROM archlinux

ADD --chown=0:0 files /

RUN pacman-key --init
RUN pacman -Syu --noconfirm --needed base-devel git

RUN useradd --user-group --home-dir /var/cache/builder --create-home --system builder
RUN chmod ug+ws /var/cache/builder
RUN setfacl -m u::rwx,g::rwx /var/cache/builder

USER builder
WORKDIR /var/cache/builder
RUN \
    git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    makepkg -si --needed --noconfirm && \
    cd .. && \
    rm -rf yay

# RUN yes '' | yay -Syu --noconfirm --needed firefox slack-desktop zoom bcompare clion clion-gdb clion-jre clion-lldb makemkv ccextractor
