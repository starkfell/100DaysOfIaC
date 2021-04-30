# Markdown Cheat Sheet

This is a concise and easy-to-navigate markdown cheat sheet. The list covers markdown in general, but also includes some  Github Flavored Markdown (GFM) where GFM is a bit different from standard markdown. For each markdown style, you will see two entries:

- The first entry shows the syntax for the given style
- The second shows how the syntax renders in a browser

Use the 'Table of Contents' and 'back to top' links to navigate this document quickly and easily.

# Table of Contents

- [Markdown Cheat Sheet](#markdown-cheat-sheet)
- [Table of Contents](#table-of-contents)
- [Headers](#headers)
- [H1](#h1)
  - [H2](#h2)
    - [H3](#h3)
      - [H4](#h4)
        - [H5](#h5)
          - [H6](#h6)
- [Formatting / Emphasis](#formatting--emphasis)
- [Lists](#lists)
    - [Numbered Lists](#numbered-lists)
    - [Unordered Lists](#unordered-lists)
    - [Mixing Ordered and Unordered Lists](#mixing-ordered-and-unordered-lists)
- [Hyperlinks](#hyperlinks)
- [Blockquotes](#blockquotes)
- [Tables](#tables)
- [Images](#images)
- [Code](#code)
- [Line Breaks](#line-breaks)
- [Horizontal Rule](#horizontal-rule)
- [Inline HTML](#inline-html)

# Headers

\# H1

\## H2

\### H3

\#### H4

\##### H5

\###### H6


# H1
## H2
### H3
#### H4
##### H5
###### H6

[back to top](#markdown-cheat-sheet)

# Formatting / Emphasis

``Italic - use *asterisks* or _underscores_.``

``Bold - use double **asterisks** or __underscores__.``

``Combined emphasis - use **asterisks and _underscores_** together.``

``Strikethrough uses two tildes. ~~nevermind, scratch that.~~``

And these render as follows:

Italic - use *asterisks* or _underscores_.

Bold - use **asterisks** or __underscores__.

Combined emphasis - use **asterisks and _underscores_** together.

Strikethrough uses two tildes. ~~nevermind, scratch that.~~

[back to top](#markdown-cheat-sheet)
# Lists 
There are two types of lists: Numbered (aka ordered) lists, and unordered lists.

### Numbered Lists 

1. First ordered list item
2. Second ordered list item
3. Lists are not auto-numbered. You can use any number you want, as long as its a number.

### Unordered Lists 
* Unordered list can use asterisks
- Or minuses
+ Or pluses

### Mixing Ordered and Unordered Lists
You can mix the two lists types when you need to. For the sublist item, the number of spaces is important (I used dashes for the spaces on the sub-item).

1\. item number 1 
2\. item number 2
---* Unordered sublist item.

which renders like this: 

1. item number 1 
2. item number 2
   * Unordered sublist item. 

[back to top](#markdown-cheat-sheet)

# Hyperlinks 

There are several types of links:

[inline-style link](https://www.msdn.com)

[I'm an inline-style link with title](https://www.msdn.com "MSDN homepage")

[I'm a reference-style link][arbitrary case-insensitive reference text]

\[I'm a relative reference to a repository file](azure.png)

which renders like this:

[I'm a relative reference to a repository file](azure.png)

[You can use numbers for reference-style link definitions][1]

leave it empty and use the [link text itself].

Finally, URLs and URLs in angle brackets will automatically be converted to links. 
https://www.msdn.com or <https://www.mdsn.com>. Some tools and platforms support dropping the https://, like msdn.com, but some dont (like Github), so add the https:// to ensure consistent behavior.

[back to top](#markdown-cheat-sheet)
# Blockquotes 
Blockquotes are great for a long string of text you want to be sure gets noticed, even if it line wraps. I think of it like comment boxes in MS Word. just use the 'greater than' sign. 

\> This is my quote I want to call out.

and this is what it looks like:
> This is my quote I want to call out. 

[back to top](#markdown-cheat-sheet)
# Tables 
Tables are supported by GFM, but are not part of basic Markdown. You can use colons to align your table columns, as shown below. Note the single right colon in column 2 means right-aligned, the colons to left and right of column 4 means center-aligned. Column 1 is left-aligned (the default).

\| Column 1      | Column 2        | Column 3   |

\| ------------- |---------------: | :--------: |

\| col 3 is      | center-aligned  | test       |

\| col 2 is      | right-aligned   | dev        |

\| col 1 is      | left-aligned    | prod       |

which renders like this:

| Column 1      | Column 2        | Column 3   |
| ------------- |---------------: | :--------: |
| col 3 is      | center-aligned  | test       |
| col 2 is      | right-aligned   | dev        |
| col 1 is      | left-aligned    | prod       |



[back to top](#markdown-cheat-sheet)
# Images 

Here's an image, and if hover over with your mouse, you see the title text). There are two types of images references:

There is **Inline-style**, which points directly to image and includes alt text:

\![alt text] (https://raw.githubusercontent.com/pzerger/cheatsheets/master/azure.png "Alternate Title Text 1")

![alt text](https://raw.githubusercontent.com/pzerger/cheatsheets/master/azure.png "Alternate Title Text 1")

Then, there is **Reference-style**, where I can refer to an image aliased elsewhere in the markdown:

\![alt text]\[myalias]

\[myalias]: https://raw.githubusercontent.com/pzerger/cheatsheets/master/azure.png "Alternate Title Text 2"

![alt text][myalias]

'myalias' in the above is a reference (or alias) defined anywhere in my markdown document, as shown below. This is handy if you want to reference an image with a long external URL multiple times.

[myalias]: https://raw.githubusercontent.com/pzerger/cheatsheets/master/azure.png "Alternate Title Text 2"

> NOTE: At this time, there is no syntax for defining a specific image size. As a workaround, you can reference the image with inline HTML using the <img> tag.

[back to top](#markdown-cheat-sheet)
# Code 

Inline `code` has `back-ticks around` it.

Blocks of code are either fenced by lines with three back-ticks ```

Github Flavored Markdown supports highlighting language-specific formatting for a _very_ long list of languages known to Github, listed HERE https://github.com/github/linguist/blob/master/lib/linguist/languages.yml. Just a couple of examples:

\```python

ps = "string in a Python varible"

print ps

\```

which renders like this:

```python
ps = "string in a Python varible"
print ps
```

\```javascript

var js = "string in a JavaScript varible";

print js;

\```

which renders like this:

```javascript

var js = "string in a JavaScript varible";

print js;

```

[back to top](#markdown-cheat-sheet)
# Line Breaks
--
[back to top](#markdown-cheat-sheet)
# Horizontal Rule 
A horizontal rule is a grey line. You can add a horizontal rule using three asterisks or three dashes.

\***

\---

[back to top](#markdown-cheat-sheet)
# Inline HTML 
 If you just use the normal HTML tags, it usually works reasonably well. 

[back to top](#markdown-cheat-sheet)
