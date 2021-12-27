# tile
A lite weight window tiling utility

## Install
``` sh
cd tile
make install
```

## Layout config
Layout configuration is stored at ~/.tile/layout.json
``` json
[
    {
        "comment":"Matches monitors wider than 3000px and creates a 3x2 grid",
        "minWidth":3000,
        "gap":10,
        "cols":[
            {
                "rows":[
                    {},{}
                ]
            },
            {
                "flex":1.5,
                "rows":[
                    {},{}
                ]
            },
            {
                "flex":1.5,
                "rows":[
                    {},{}
                ]
            }

        ]
    },
    {
        "comment":"Matches all other monitors and creates a 2x2 grid",
        "cols":[
            {
                "rows":[{},{}]
            },
            {
                "rows":[{},{}]
            }

        ]
    }
]
```

## Usage
``` sh

# Move active right one column
tile -move right

# Move active left one column
tile -move left

# Move active up one row
tile -move up

# Move active down one row
tile -move down

# auto layouts out all window on screen
tile -auto-layout
```