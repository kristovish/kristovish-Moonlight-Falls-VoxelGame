# getname - Minetest name generator (utility mod)

This Minetest mod is intended as a helper to other mods that need to generate
random names for NPCs, mobs, and places. I originally wanted to add proper names
to the AliveAI mod, and it seemed sensible to just make it generic so other
mods could use it too.

Although intendeed to be used by other mods, it can be quite useful for getting
ispiration when world building - names can give a picture of what might be.

The names of people that can be generated are all derived from WikiMedia categories:
`Male_names`, `Female_names`, `Unisex_names`, and `Surnames`. As structured data, the
lists of names fall under the Creative Commons CC0 License (Public Domain).

The pet names lists have been compiled by my own dilligent research on the Internet,
and are also released under the Creative Commons CC0 License.

The place names were extracted from the Ordnance Survey OpenPlaces data set, which is
covered by the Open Government License (OGL), which simply requires the attribution
message 'Contains OS data © Crown copyright and database right 2020'.

The API is as follows.

    forename() - return a forename (any gender)
    surname() - return a surname

    genderlessName() - return genderless forename
    feminineName() - return feminine forename
    masculineName() - return masculine forename

    dogName()
    dogNameFemale()
    dogNameMale()

    catName()
    catNameFemale()
    catNameMale()

So, assuming the mod is loaded, it can be used as follows: -

```
    local myRandomName = getname.genderlessName()
    local fullName = getname.forename() .. ' ' .. getname.surname()
```

There are also generators for places, but they don't have specific APIs. You
can access all the underlying name generators using getnameCall(), which
accepts as a parameter any of the above APIs or any of the generator names.

```
    -- use getnameCall to invoke a generator directly
    local villageName = getnameCall('place_village')

    -- getnameCall can also be passed an API name, if you prefer
    local myRandomName = getnameCall('masculineName')
```

The mod also registers the chat command `/getname`, which takes the API
function name or an underlying generator name as a parameter, and returns its
result. For example: -

```
    /getname feminineName
    /getname place_street
```

will result in a full name being sent to the player's chat window. Note that
parentheses are not used, just the function name.

The list of generators (basically the files from which names are taken) are
currently as follows, though using `/help getname` will give you the definitive
list.

```
<feminine> <masculine> <genderless> <surname>

<dog_female> <dog_male> 
<cat_female> <cat_male> 

<place_village> <place_street> <place_hamlet> <place_hill> 
<place_mountain> <place_wetland> <place_coastal> <place_island>
```

Places are taken from real UK place names, limited to 5000 randomly chosen
entries that contain only ASCII characters (to avoid issues when using with
signs, for example). I can supply the original files and scripts to extract if
anyone wants to create bigger, or more comprehensive lists. Just email me
(kevin@susa.net).

### The stamper tool

The tool `getname:stamper` can be used to stamp a random name onto a sign
(currently only signs managed by `signs_lib`). If you use the tool with a sign (i.e.
punch), then a random string will be written to the sign. By default, street
names are written.

The crafting recipe is:

```
    ----   clay_lump   ----
    ----  steel ingot  ----
    ----     stick     ----
```

If you right-click (i.e. place) the tool on a non-sign node, then a chooser
form is shown allowing the selection of the stamp type (e.g. street, village,
mountain, etc.).

### Adding your own name lists

This is a simple mod that you can easily modify to handle different name (or
any random short string) generation. It reads directly from disk to choose a
name, rather than reading everything into RAM, so your lists can be huge, and
it won't matter.

Name lists should be placed in the mod directory under `lists/`, and should
have one name per line. Add an entry in the generators table with the name of
your new file, and a add a function to the `getname` table of API functions to
call your generator.

It works by choosing a 32 byte block in the file, and seeking to it plus a
random offset of half this block size to avoid names being missed at
boundaries. It then reads enough lines into a table (i.e. maximum of 20) and
chooses one at random. If your strings are longer than half the block size,
then just increase it.

### License: GPLv3 for all code in this mod.
