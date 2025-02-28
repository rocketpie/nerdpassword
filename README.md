# NerdPassword
Mnemonic passwords done ~~right~~ a little better.  
strike that. It' my attempt at prematurely optimizing a dead technology :) 

To start off, a quick reference to the all-time nerd hero Randall Munroe:  
https://xkcd.com/936/

And a shoutout to Ross Anderson:  
https://www.cl.cam.ac.uk/archive/rja14/book.html


## 'done right', huh? what's wrong with the others? 
## re-roll security

### inconsistent word length
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


### more shord words

If we just had more 3 or 4 letter words, we'd get more consistent passwords with better security.  
But we need to be careful.
The reason we use 'words' instead of random characters, is that words are *highly recognizable*

These are EFF's three letter words:  
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

