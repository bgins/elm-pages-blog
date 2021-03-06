---
{
  'type': 'blog',
  'author': 'Brian Ginsburg',
  'title': 'Markdown Test',
  'description': 'Test of markdown renderer',
  'image': 'images/blog/markdown-test/markdown-test.jpg',
  'draft': true,
  'published': '2021-03-06',
}
---

Plain text. _Itatilc_. **Bold**. ~~Strikethrough~~.

**_Bold and Itatilc_**. _~~Italic and struck through~~_. **~~Bold and struck through~~**. _**~~Bold, Italic, and struck through~~**_.

[A link](https://example.com). [_Italic link_](https://exmaple.com).
[**Bold link**](https://example.com). [~~Struck through link~~](https://example.com)

`Code span`

# Heading 1
## Heading 2
### Heading 3
#### Heading 4
##### Heading 5
###### Heading 6

Unordered list
- Item
- **Bold item**
- _Italic item_

Ordered list
1. Item
2. **Bold item**
3. _Italic item_

Block quote
> This is a block quote. Here comes the Lorem ipsum dolor sit amet,
> consectetur adipiscing elit, sed do eiusmod tempor incididunt ut 
> labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud 
> exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. 
> Duis aute irure dolor in reprehenderit in voluptate velit esse cillum 
> dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non 
> proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

Thematic break

---

Code block
```elm
type alias Voice =
    { id : String
    , frequency : Float
    , pattern : Pattern
    }
```
Image

![Image](/images/blog/markdown-test/markdown-test.jpg)