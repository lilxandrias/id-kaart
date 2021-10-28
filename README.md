# ID-kaart
ID-kaarditarkvara automaatse paigaldamise skriptid / ID-card automated installation scripts

## manjaro-id-kaart.sh
* Lisateave eesti keeles - https://viki.pingviin.org/ID-kaart_Manjaro_Linuxis
* mõeldud kasutamiseks [Manjaro Linuxis](https://manjaro.org/). Sobib ka [Arch Linuxile](https://archlinux.org/) jt [selle põhjal tehtud distrotele](https://distrowatch.com/search.php?ostype=Linux&category=All&origin=All&basedon=Arch&notbasedon=None&desktop=All&architecture=All&package=All&rolling=All&isosize=All&netinstall=All&language=All&defaultinit=All&status=Active#simple).
* designed for use with [Manjaro Linux](https://manjaro.org/). Also suitable for [Arch Linux](https://archlinux.org/) and [other distros made on this basis](https://distrowatch.com/search.php?ostype=Linux&category=All&origin=All&basedon=Arch&notbasedon=None&desktop=All&architecture=All&package=All&rolling=All&isosize=All&netinstall=All&language=All&defaultinit=All&status=Active#simple).
* paigaldamine / installation
  * wget -q --show-progress -O $(xdg-user-dir DOWNLOAD)/manjaro-id-kaart.sh https://koodivaramu.eesti.ee/alvatal/id-kaart/-/raw/main/manjaro-id-kaart.sh
  * sh $(xdg-user-dir DOWNLOAD)/manjaro-id-kaart.sh
