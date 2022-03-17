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

# web-eid, chromium-extension-web-eid, firefox-extension-web-eid
# Mart Sõmermaa
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=web-eid
wget -q -O- https://github.com/mrts.gpg|gpg --import -

# automatiseeritult kõikide imporditud GPG-võtmete täielik usaldamine
for i in $(gpg --list-keys --with-colons --fingerprint | sed -n 's/^fpr:::::::::\([[:alnum:]]\+\):/\1/p') ; do printf "trust\n5\ny\nquit" | gpg -q --no-tty --command-fd 0 --status-fd 2 --expert --edit-key $i 2>/dev/null 1>/dev/null ; done

##################################
# ID-KAARDITARKVARA PAIGALDAMINE #
##################################
# paigaldame ID-kaarditarkvara AUR'ist, sudo pole yay puhul lubatud
# siiski pacmani käivitumisel kasutatake sudo automaatselt
#
# varasem paigaldus
# yay -S qdigidoc4 chrome-token-signing esteidpkcs11loader --noconfirm --needed --cleanafter
#
# alates 15.03.2022 tulnud web-eid tugi
yay -S qdigidoc4 web-eid chromium-extension-web-eid firefox-extension-web-eid esteidpkcs11loader --noconfirm --needed --cleanafter
#
# kui siiski internetipangas vms ei toimi ID-kaart kuna pole jõutud Web eID'd kasutusele võtta, siis paigaldada ka see pakett
# yay -S chrome-token-signing --noconfirm --needed --cleanafter

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
# kui muu ei aita, siis eemaldada failid ja lisada kõik uuesti
# rm -fr $HOME/.pki/nssdb/*
# ja siis ülalt pikk rida uuesti sisestada
#
# kui moodul on lisatud, siis teist korda sama moodulit lisada ei saa
# siis tuleb kõigepealt eemaldada

# # # # # #
# FIREFOX #
# # # # # #
# Firefoxis võib olla vajalik lisada käsitsi turvamoodul, kui seda mingil põhjusel ei ole tekkinud.
# Turvaseadmed -> Laadi
# Nimi: OpenSC smartcard
# asukoht: /usr/lib/onepin-opensc-pkcs11.so
#
# Lisaks kasulik automaatne sertifikaadi valimine Firefoxis
# aadressireale kirjutada about:config ja vajutada Enter ning olla nõus hoiatusega
# otsida üles parameeter security.default_personal_cert
# vaikimisi: Ask Every Time
# automaatne režiim: Select Automatically

# # # # # #
# Web eID #
# # # # # #
# Ametlik uudis:
# EST https://www.ria.ee/et/uudised/id-tarkvara-varske-versioon-sai-uuendusliku-web-eid-liidese.html
# ENG https://www.ria.ee/en/news/latest-version-id-software-includes-innovative-web-eid-interface.html
# RUS https://www.ria.ee/ru/novosti/poslednyaya-versiya-programmnogo-obespecheniya-dlya-id-karty-poluchila-innovacionnyy-veb.html
# 
# Web eID seadistamine
# EST https://www.id.ee/artikkel/veebibrauserite-seadistamine-id-kaardi-kasutamiseks/
# ENG https://www.id.ee/en/article/configuring-browsers-for-using-id-card/
# RUS https://www.id.ee/ru/artikkel/nastrojka-veb-brauzerov-dlya-ispolzovaniya-id-karty/

#########################################
# PC/SC TEENUSE LUBAMINE JA KÄIVITAMINE #
#########################################
sudo systemctl enable pcscd.socket
sudo systemctl restart pcscd.socket
