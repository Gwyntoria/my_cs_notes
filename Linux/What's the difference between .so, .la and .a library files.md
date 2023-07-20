# What's the difference between .so, .la and .a library files?

`.so` files are **dynamic libraries**. The suffix stands for **"shared object"**, because all the applications that are linked with the library use the same file, rather than making a copy in the resulting executable.

`.a` files are **static libraries**. The suffix stands for **"archive"**, because they're actually just an archive (made with the `ar` command -- a predecessor of `tar` that's now just used for making libraries) of the original `.o` object files.

`.la` files are **text files used by the GNU "libtools" package** to describe the files that make up the corresponding library. You can find more information about them in this question: [What are libtool's .la file for?](https://stackoverflow.com/questions/1238035/what-is-libtools-la-file-for)

## Reference

1. [What's the difference between .so, .la and .a library files?](https://stackoverflow.com/questions/12237282/whats-the-difference-between-so-la-and-a-library-files)
