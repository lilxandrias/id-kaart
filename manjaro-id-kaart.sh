#!/bin/sh

# Skript algselt kirjutatud Manjaro Linuxile.

# ID-kaarditarkvara automaatse paigaldamise skript
# Arch Linuxile ja sellepõhistele distrotele
# Skripti koostas: Edmund Laugasson
# Testis ja nõu andis: Arvo Mägi
# Lisateave https://viki.pingviin.org/ID-kaart_Manjaro_Linuxis

# Allolev skript võiks toimida mitte ainult Manjaro Linuxis, vaid ka Arch Linux jt Arch Linuxi põhjal tehtud distrod - https://distrowatch.com/search.php?ostype=Linux&category=All&origin=All&basedon=Arch&notbasedon=None&desktop=All&architecture=All&package=All&rolling=All&isosize=All&netinstall=All&language=All&defaultinit=All&status=Active#simple

# Käesolev skript on testitud:
# - Manjaro Linux https://manjaro.org/
# - EndeavourOS https://endeavouros.com/

#######################
# Skripti käivitamine #
#######################
# sh skript.sh
# osa käske (nt yay) peavad minema tööle tavakasutajana

##################
# Peegelserverid #
##################
# leiame kiiremad peegelserverid
# see võib teinekord põhjustada siiski segadust, lubada kui muidu ei toimi
# sudo pacman-mirrors -f 5

#######################
# Süsteemi uuendamine #
#######################
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
# võtame GPG-võtme otse AURi serverist
gpg --keyserver $keyserver --recv-keys $(curl -fsSL "https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=xml-security-c" | grep validpgpkeys | cut -d";" -f2 | rev | cut -d"&" -f2 | rev)

# libdigidocpp, qdigidoc4, esteidpkcs11loader, chrome-token-signing
gpg --keyserver $keyserver --recv-keys $(curl -fsSL "https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libdigidocpp" | grep "Raul Metsma" | cut -d";" -f2 | rev | cut -d"&" -f2 | rev)

# web-eid, chromium-extension-web-eid, firefox-extension-web-eid
# Mart Sõmermaa
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=web-eid
wget -q -O- https://github.com/mrts.gpg|gpg --import -

##########################
# GPG-VÕTMETE USALDAMINE #
##########################
# automatiseeritult kõikide imporditud GPG-võtmete täielik usaldamine
for i in $(gpg --list-keys --with-colons --fingerprint | sed -n 's/^fpr:::::::::\([[:alnum:]]\+\):/\1/p') ; do printf "trust\n5\ny\nquit" | gpg -q --no-tty --command-fd 0 --status-fd 2 --expert --edit-key $i 2>/dev/null 1>/dev/null ; done

##################################
# ID-KAARDITARKVARA PAIGALDAMINE #
##################################
# paigaldame ID-kaarditarkvara AUR'ist, sudo pole yay puhul lubatud
# siiski pacmani käivitumisel kasutatake sudo automaatselt

# varasem paigaldus
# yay -S qdigidoc4 chrome-token-signing esteidpkcs11loader --noconfirm --needed --cleanafter

# alates 15.03.2022 tulnud Web eID tugi
yay -S qdigidoc4 web-eid esteidpkcs11loader --noconfirm --needed --cleanafter

# Kui siiski internetipangas või mujal ei toimi ID-kaart, kuna pole jõutud Web eID'd kasutusele võtta, siis paigaldada ka see pakett
# yay -Syu chrome-token-signing --noconfirm --needed --cleanafter && yay -Scc --noconfirm

# Olgu mainitud, et chromium-extension-web-eid firefox-extension-web-eid paketid on vaid testimiseks AURis olemas.
# https://aur.archlinux.org/packages/chromium-extension-web-eid
# https://aur.archlinux.org/packages/firefox-extension-web-eid
#
# Kui siiski soovitakse testimise, arenduse eesmärgil paigaldada, siis:
# yay -S chromium-extension-web-eid firefox-extension-web-eid --noconfirm --needed --cleanafter && yay -Scc --noconfirm
#
# Eemaldamiseks
# yay -Rn chromium-extension-web-eid firefox-extension-web-eid

# paigaldame ametlikust varamust ID-kaardilugejate tarkvara
# juhul kui seda ei olnud eelnevalt paigaldatud
sudo pacman -S ccid --needed --noconfirm

#puhastame paketihaldurite vahemälu paigaldatud tarkvarast
sudo pacman -Scc --noconfirm
yay -Scc --noconfirm

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

#########################################
# PC/SC TEENUSE LUBAMINE JA KÄIVITAMINE #
#########################################
sudo systemctl enable pcscd.socket
sudo systemctl restart pcscd.socket

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

# Sertifikaadiga automaatselt nõustumisest Chromiumis jt analoogides
# sätted
# chrome://settings/certificates
# brave://settings/certificates
# seal saab PIN1 sertifikaadi välja eksportida, base64 kodeeritud ASCII vormingus
#
# seadistamine:
# https://chromeenterprise.google/policies/#AutoSelectCertificateForUrls

cat << EOF

NB! KASUTAJATEL TULEB ISE PAIGALDADA Web eID VEEBILEHITSEJATE LAIENDUSED!
-------------------------------------------------------------------------
Ametlik uudis Web eID kasutuselevõtu kohta alates 15.märtsist 2022:
https://www.ria.ee/et/uudised/id-tarkvara-varske-versioon-sai-uuendusliku-web-eid-liidese.html

Vajalik võib olla ka käsitsi laienduse lubamine veebilehitsejas!
https://www.id.ee/artikkel/veebibrauserite-seadistamine-id-kaardi-kasutamiseks/

Kindlasti tasub üle kontrollida Web eID laienduse lubamine
privaatses, tundmatus veebilehitseja režiimis.

Kui teenusepakkuja pole jõudnud Web eID'd kasutusele võtta, siis võib
vajalik olla chrome-token-signing paketi paigaldamine. Lisateavet leiab
käesoleva skripti kommentaaridest. Kui tekib konflikt, siis tasub alles jätta Web eID
ja vanema teenuse puhul näiteks Smart-ID või muud nutiseadme-põhist
lahendust kasutada kuniks teenusepakkuja ka Web eID peale ära on uuendanud.

CHROMIUMi Web eID laiendus
--------------------------
... ja sellepõhised veebilehitsejad (Google Chrome, Brave, jt)
https://chrome.google.com/webstore/detail/web-eid/ncibgoaomkmdpilpocfeponihegamlic

FIREFOXi Web eID laiendus
-------------------------
https://addons.mozilla.org/en-US/firefox/addon/web-eid-webextension/

Firefoxi turvamooduli lisamine käsitsi
--------------------------------------
Firefoxis võib olla vajalik lisada käsitsi turvamoodul,
kui seda mingil põhjusel ei ole tekkinud:
- about:preferences#privacy (sisestada aadressireale + vajutada Enter)
- Turvaseadmed -> Laadi
- Nimi: OpenSC smartcard
- asukoht: /usr/lib/onepin-opensc-pkcs11.so

Automaatne sertifikaadi valimine Firefoxis
------------------------------------------
- aadressireale kirjutada
about:config
...ja vajutada Enter ning olla nõus hoiatusega
- otsida üles parameeter:
security.default_personal_cert
- vaikimisi on seal väärtus:
Ask Every Time
- automaatse režiimi sisselülitamiseks kirjutada selle asemele:
Select Automatically
- salvestada muudatus - vajutada Enter või rea lõpus vastav nupp

Web eID lisateave ja laienduse testimine
----------------------------------------
https://web-eid.eu/

Seal võimalik testida nii isikutuvastust kui digiallkirjastamist.

EOF
