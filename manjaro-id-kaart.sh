#!/bin/sh
 
# skript käivitada
# sh skript.sh
# osa käske peavad minema tööle tavakasutajana
 
# leiame kiiremad peegelserverid
# see võib teinekord põhjustada siiski segadust, lubada kui muidu ei toimi
# sudo pacman-mirrors -f 5  
 
# uuendame tarkvarapakettide andmebaasid ja kogu süsteemi
# peale uuendamist tühjendame pacmani vahemälu
sudo pacman -Syyu --noconfirm
sudo pacman -Scc --noconfirm
 
################################################
# AURi pakettide paigaldamise ettevalmistamine #
################################################
# Paigaldame yay ja kompileerimiseks vajalikud abiprogrammid
# juhul kui neid ei olnud eelnevalt paigaldatud
sudo pacman -S yay --needed --noconfirm
sudo pacman -S base-devel --needed --noconfirm
 
###############
# VÕTMESERVER #
###############
# GPG-võtmeservereid
# keyserver.ubuntu.com
# keys.openpgp.org
# https://wiki.archlinux.org/title/GnuPG#Key_servers
keyserver=keyserver.ubuntu.com
 
###########################
# GPG-VÕTMETE IMPORTIMINE #
###########################
# Puuduvate GPG-võtmete importimine eelnevalt
# xml-security-c
# võtame GPG-võtme sõrmejälje otse AURi serverist
gpg --keyserver $keyserver --recv-keys $(curl -fsSL "https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=xml-security-c" | grep validpgpkeys | cut -d";" -f2 | rev | cut -d"&" -f2 | rev)
#
# libdigidocpp, qdigidoc4, esteidpkcs11loader, chrome-token-signing
gpg --keyserver $keyserver --recv-keys $(curl -fsSL "https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libdigidocpp" | grep "Raul Metsma" | cut -d";" -f2 | rev | cut -d"&" -f2 | rev)
 
# automatiseeritult kõikide imporditud GPG-võtmete täielik usaldamine
for i in $(gpg --list-keys --with-colons --fingerprint | sed -n 's/^fpr:::::::::\([[:alnum:]]\+\):/\1/p') ; do printf "trust\n5\ny\nquit" | gpg -q --no-tty --command-fd 0 --status-fd 2 --expert --edit-key $i 2>/dev/null 1>/dev/null ; done
 
##################################
# ID-KAARDITARKVARA PAIGALDAMINE #
##################################
# paigaldame ID-kaarditarkvara AUR'ist, sudo pole yay puhul lubatud
# siiski pacmani käivitumisel kasutatake sudo automaatselt
yay -S qdigidoc4 chrome-token-signing esteidpkcs11loader --noconfirm --cleanafter
 
# paigaldame ametlikust varamust ID-kaardilugejate tarkvara
# juhul kui seda ei olnud eelnevalt paigaldatud
sudo pacman -S ccid --needed --noconfirm
 
#puhastame paketihaldurite vahemälu paigaldatud tarkvarast
sudo pacman -Scc --noconfirm
sudo yay -Scc --noconfirm
 
######################################################################
# CHROMIUMI JA SELLEPÕHISTE VEEBILEHITSEJATE JAOKS VAJALIK SEADISTUS #
######################################################################
# see on kasutajaspetsiifiline seadistus
# tuleb käivitada iga kasutaja all üks kord
modutil -dbdir sql:$HOME/.pki/nssdb -add opensc-pkcs11 -libfile onepin-opensc-pkcs11.so -mechanisms FRIENDLY -force 2>/dev/null
 
# kontroll:
# modutil -dbdir sql:$HOME/.pki/nssdb -list
# peab teiste hulgas näitama lisatud opensc-pkcs11 moodulit
 
# vajadusel kustutamine kinnitust küsimata
# modutil -dbdir sql:$HOME/.pki/nssdb -delete onepin-opensc-pkcs11 -force
# VÕI ka
# modutil -dbdir sql:$HOME/.pki/nssdb -delete opensc-pkcs11 -force
#
# kui moodul on lisatud, siis teist korda sama moodulit lisada ei saa
# siis tuleb kõigepealt eemaldada
 
#########################################
# PC/SC TEENUSE LUBAMINE JA KÄIVITAMINE #
#########################################
sudo systemctl enable pcscd.socket
sudo systemctl restart pcscd.socket
