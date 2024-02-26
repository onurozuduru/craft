# Craft
This is a small script to generate a new script file basically by glueing set of input files together.

The idea is keeping each part of a script in their dedicated file, preferably sorted by functionality for sake of simplicity.
And instead of sourcing those smaller parts aim is to create one big static script file.

It is also possible to split into smaller files again, after making changes on the generated file.

Probably there is a better tool to do this, but it is more fun to create my own buggy and simple tool 😄

## Usage

```bash
Usage: ./craft.sh [ -g | --glue <FILE> [ -p | --permanent ] [ --shebang <SHEBANG> ] <FILES> ] [ -s | --split <FILE> [ -o | --out <DIR> ] ] [ --overwrite ] [ -h | --help ]
Craft new scripts. Glue script pieces together or split previously glued script.
  -h,--help       Display help.
  --overwrite     Overwrite files.
  -g,--glue <FILE> Glue mode, copy contents of given files to <FILE>:
    -p,--permanent          Do not put tags, files generated with this flag cannot be used for split mode.
    --shebang <SHEBANG>     Shebang to use for generated files, default: '#!/bin/bash'
    Example: ./craft.sh -g output.sh -p -s "#!/bin/sh" -i input_first_part.sh input_second_part.sh
  -s,--split <FILE> Split mode, split <FILE> that has glue tags:
    -o,--out <DIR>  Generate files under <DIR>, default: '.'
    Example: ./craft.sh -s input.sh -o output_dir/
```

## Examples

Crafting the `craft.sh`:
```bash
./craft.sh --overwrite --glue craft.sh sources/header sources/common.sh sources/glue_mode.sh sources/split_mode.sh sources/craft.sh
```

After editing, splitting back to small files (assuming auto generated tags are **untouched**):
```bash
./craft.sh --split craft.sh -o sources --overwrite
```

If it is not needed, auto generated tags can be removed by giving `--permanent` or `-p` flag:

⚠️ **WARNING**: It is not possible to use `--split` afterwards since, `craft.sh` cannot know what to do with the input without tags and file names attached to those tags.
```bash
./craft.sh --permanent --glue craft.sh sources/header sources/common.sh sources/glue_mode.sh sources/split_mode.sh sources/craft.sh
```
