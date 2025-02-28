# NerdPassword
Mnemonic passwords done ~~right~~ ~~a little better~~.  
~~'done right', huh? what's wrong with the others?~~  
strike that. This is just my attempt at prematurely optimizing a dead technology :) 

To start off, a quick reference to the all-time nerd hero Randall Munroe:  
https://xkcd.com/936/

And a shoutout to Ross Anderson:  
https://www.cl.cam.ac.uk/archive/rja14/book.html



## Re-roll security 


### Inconsistent word length
passphrase generators like
* https://www.useapassphrase.com/
* the one built into https://bitwarden.com/password-generator/

use either dashes, spaces or capital letters to delimit words.  
They also use wordlists like this long one from EFF: https://www.eff.org/dice
```
...
aerospace
afar
affair
affected
affecting
...
```

Let's take a look at a two 4-word phrases from this list, using common formatting: 
* `Affiliate-Skincare-Spherical-Outboard`
* `dish-nag-upon-aim`

one of these requires pressing 41 keys, the other one 17.  
Both of them provide the same security assumption: 

$$ \log_2 listsize^{wordcount} => \log_2 7776^{4} \approx 51 $$

51 bits of entropy is ok for a password, if it can't be used offline.  

But that's *only if* you follow schneier's advice literally,  
using random chance, *without messing with it*.

I think the fact that these vary so wildly different in length  
*will* make the user mess with it, and re-roll the dice until the password is short enough.

This is the word-length distributing in this list:
```
length (wordcount)
3 (  82): ####
4 ( 467): #####################
5 ( 927): ##########################################
6 (1372): ##############################################################
7 (1590): ########################################################################
8 (1778): ################################################################################
9 (1556): ######################################################################
```

let's make the user re-roll a few times, until...  
there: `dial-banana-voter-thing`, 23 characters.

if you can get a passphrase of 24 characters or less in a few rolls,  
why would you use one with 36?

Here's a length distribution over 1000 4-word phrases from this list:
```
phraselength (samples)
19 (  1): #
20 (  1): #
22 (  4): ##
23 (  4): ##
24 ( 12): #######
25 ( 26): ################
26 ( 41): ########################
27 ( 59): ###################################
28 ( 73): ############################################
29 (103): #############################################################
30 (106): ###############################################################
31 (134): ################################################################################
32 (108): ################################################################
33 (115): #####################################################################
34 ( 87): ####################################################
35 ( 71): ##########################################
36 ( 29): #################
37 ( 20): ############
38 (  5): ###
39 (  1): #
```

Let's assume user's will re-roll when there's at least one 7 character word in their password.  
This will effectively shrink the wordlist from 7776 to 2852 words.

$$ \log_2 listsize^{wordcount} => \log_2 2852^{4} \approx 45 $$

That's why I believe, this method isn't *re-roll safe*.


## More shord words

If we just had more 3 or 4 letter words, we'd get more consistent passwords with better security.  
But we need to be careful.
The reason we use 'words' instead of random characters, is that words are *highly recognizable*

These are all of EFF's three letter words:  
aim art bok bud cod cot cub cut dab dad dig dot dry dug duo eel elf elk elm emu fax  
fit foe fog fox gag gap gas gem gig gut guy hub hug hut ice icy ion ivy jab jam jet  
job jog jot joy keg lid lip map mom mop mud mug nag nap net oak oat oil old opt owl  
pep pod pry pug rug rut sax say set shy sip sky tag try tug tux wad wok yam

That's good.

But what about 'bmw'? 'cia'? those are also highly recognizable, aren't they?  
for some folks, even 'bgp' and 'tcp' are highly recognizable.  
For some others, 'mon', 'tue', etc. or 'nnw', 'ssw'.  
I think there's many more.   

Many of them are only recognizable when your'e a nerd in that space.  
but, and this is crucial:  
I believe that re-rolling when some word's don't 'klick' with you is so specific to the user  
that no attacker can generally remove them from the list.

let's try 
## The nerd list

It's a list of thre letter words that I've reckognized while scrolling through a list of *all* possible three letter words.
it contains english words, acronyms, agency names, german words, company names, weekdays, protocol identifiers, you name it.

let's give it a try. To make it fair, we'll compare 51 bits of entropy, with 10 examples from each list:
```
eff-long:
distill-spectacle-pursuable-unworthy
tipped-absentee-track-wages
florist-anybody-supernova-automated
armed-conjure-porridge-bubbly
shock-playlist-criteria-boundless
coaster-sultry-emission-snowshoe
grower-scanning-discolor-unaltered
reconfirm-exonerate-why-suds
pending-jalapeno-exponent-matriarch
ensnare-backboned-provable-tadpole

eff-short:
acorn-chair-pulse-nacho-area
prism-rash-clasp-jog-candy
showy-grunt-drown-mace-nutty
tux-mural-tux-lived-gap
thank-user-year-watch-ozone
sky-batch-hush-aloe-duct
oven-dawn-charm-relic-argue
folk-twice-robin-stump-clone
rage-elf-near-barn-cheek
sting-spoil-gem-botch-issue

nerd:
dst-war-fdp-oci-saw
zna-pxe-vod-tns-sls
ovp-crl-pwd-ccp-std
lmn-kot-box-dig-utf
rnd-how-mia-mix-apu
chi-blc-kat-inh-ufo
pch-mac-ard-hlf-php
sla-wir-kpd-sia-bee
vet-tns-wok-sss-jau
tag-mit-mfw-zfa-nkw
```

note that you *can't* favor short phrases from eff's lists,  
but you *can* safely choose the nerd phrase you like.  

And just like xkcd and the EFF generally recommend for remembering phrases, imagine a story:  
`rnd-how-mia-mix-apu` might be remembered as `It's random how mia mixes APUs for fun!`   
`chi-blc-kat-inh-ufo` might be `chinese black cat was inhaled by ufo` - in which case I'd swap `c` and `k`

I'm sorry I can't draw a comic for these :D


## Why would you want to use a password, anyway?

I use a password manager.  

almost all of the time, that saves me all of this hassle.  
I use auto-generated 32 random character passwords I won't even get to see once.

But occasionally, I just *have* to type a password.  
Like for my windows logon.  

Mostly, I'll read it off my manager anyway, and just need to keep it in mind long enough to type.  
Like changing a service user password over an RDP connection.  
Or entering credentials in UAC or windows login prompt.

I'm working in an all windows environment and some s*** is just bad *and* unavoidable.  
One day MS might change this, but until then, i want to type as little as possible while staying secure.


## Experimenting with upredictable delimitation

capitalization and dashes help to delimit words in a passphrase.

this isn't really recognizable: `dishnaguponaim`  
but both dashes (`dish-nag-upon-aim`)  
can capitalization (`DishNagUponAim`)   
is predictable, and does not add entropy.

Let's try digits: `mace8grip6vowel1race` 

this is from the eff short list, and provides 

$$ \log_2 (listsize^{wordcount} * 10^{digitcount}) => \log_2 (1295^{4} * 1000) \approx 51 $$

51 bits in 20 characters. nice.

But 8 6 1 might not be as easily memorable as another word.  
e.g. `clink-broil-shop-atlas-muse`

$$ \log_2 listsize^{wordcount} => \log_2 1295^{5} \approx 51 $$

ok, this might not be worth the tradeoff.

