# FLAC-Tag-Editor:

</br>

</br>

![Compiler](https://github.com/user-attachments/assets/a916143d-3f1b-4e1f-b1e0-1067ef9e0401) &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: ![10 Seattle](https://github.com/user-attachments/assets/c70b7f21-688a-4239-87c9-9a03a8ff25ab) ![10 1 Berlin](https://github.com/user-attachments/assets/bdcd48fc-9f09-4830-b82e-d38c20492362) ![10 2 Tokyo](https://github.com/user-attachments/assets/5bdb9f86-7f44-4f7e-aed2-dd08de170bd5) ![10 3 Rio](https://github.com/user-attachments/assets/e7d09817-54b6-4d71-a373-22ee179cd49c)   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![10 4 Sydney](https://github.com/user-attachments/assets/e75342ca-1e24-4a7e-8fe3-ce22f307d881) ![11 Alexandria](https://github.com/user-attachments/assets/64f150d0-286a-4edd-acab-9f77f92d68ad) ![12 Athens](https://github.com/user-attachments/assets/59700807-6abf-4e6d-9439-5dc70fc0ceca)  
![Components](https://github.com/user-attachments/assets/d6a7a7a4-f10e-4df1-9c4f-b4a1a8db7f0e) : ![None](https://github.com/user-attachments/assets/30ebe930-c928-4aaf-a8e1-5f68ec1ff349)  
![Discription](https://github.com/user-attachments/assets/4a778202-1072-463a-bfa3-842226e300af) &nbsp;&nbsp;: ![FLAC Tag Editor](https://github.com/user-attachments/assets/7e513d6b-5817-4efa-8602-30c9cace5cc0)  
![Last Update](https://github.com/user-attachments/assets/e1d05f21-2a01-4ecf-94f3-b7bdff4d44dd) &nbsp;: ![102025](https://github.com/user-attachments/assets/62cea8cc-bd7d-49bd-b920-5590016735c0)  
![License](https://github.com/user-attachments/assets/ff71a38b-8813-4a79-8774-09a2f3893b48) &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: ![Freeware](https://github.com/user-attachments/assets/1fea2bbf-b296-4152-badd-e1cdae115c43)

</br>

![logo130](https://github.com/user-attachments/assets/f3c762cd-ed2a-4c04-a5e9-4bed9a0d8b8c)

</br>

FLAC stands for Free Lossless Audio Codec, an audio format similar to MP3, but lossless, meaning that audio is compressed in FLAC without any loss in quality. This is similar to how Zip works, except with FLAC you will get much better compression because it is designed specifically for audio, and you can play back compressed FLAC files in your favorite player (or your car or home stereo, see [supported devices](https://xiph.org/flac/links.html#hardware)) just like you would an MP3 file.

</br>

![FLAC Tag Editor](https://github.com/user-attachments/assets/353632d6-23fc-4708-9dfb-085cd4de5ce4)

</br>

FLAC stands out as the fastest and most widely [supported lossless audio codec](https://wiki.hydrogenaudio.org/index.php?title=Lossless_comparison), and the only one that at once is non-proprietary, is unencumbered by patents, has an open-source reference implementation, has a well documented format and API, and has several other independent implementations.

FLAC supports tagging, cover art, and fast seeking. FLAC is freely available and supported on most operating systems, including Windows, "unix" (Linux, *BSD, Solaris, OS X, IRIX), BeOS, OS/2, and Amiga.

There are many programs and devices that support FLAC, but the core FLAC project here maintains the format and provides programs and libraries for working with FLAC files. See [Getting FLAC](https://xiph.org/flac/download.html) for instructions on downloading and installing the official FLAC tools, or Using FLAC for instructions and guides on playing FLAC files, ripping CDs to FLAC, etc.

When we say that FLAC is "Free" it means more than just that it is available at no cost. It means that the specification of the format is fully open to the public to be used for any purpose (the FLAC project reserves the right to set the FLAC specification and certify compliance), and that neither the FLAC format nor any of the implemented encoding/decoding methods are covered by any known patent. It also means that all the source code is available under open-source licenses. It is the first truly open and free lossless audio format. (For more information, see the [license page](https://xiph.org/flac/license.html).)

### Notable features of FLAC:

* Lossless: The encoding of audio (PCM) data incurs no loss of information, and the decoded audio is bit-for-bit identical to what went into the encoder. Each frame contains a 16-bit CRC of the frame data for detecting transmission errors. The integrity of the audio data is further insured by storing an [MD5 signature](https://en.wikipedia.org/wiki/MD5) of the original unencoded audio data in the file header, which can be compared against later during decoding or testing.

* Fast: FLAC is asymmetric in favor of decode speed. Decoding requires only integer arithmetic, and is much less compute-intensive than for most perceptual codecs. Real-time decode performance is easily achievable on even modest hardware.

* Hardware support: FLAC is supported by dozens of consumer electronic devices, from portable players, to home stereo equipment, to car stereo.

* Flexible metadata: FLAC's metadata system supports tags, cover art, seek tables, and cue sheets. [Applications](https://xiph.org/flac/format.html#def_APPLICATION) can write their own APPLICATION metadata once they
[register an ID](https://xiph.org/flac/id.html). New metadata blocks can be defined and implemented in future versions of FLAC without breaking older streams or decoders.

* Seekable: FLAC supports fast sample-accurate seeking. Not only is this useful for playback, it makes FLAC files suitable for use in editing applications.

* Streamable: Each FLAC frame contains enough data to decode that frame. FLAC does not even rely on previous or following frames. FLAC uses sync codes and CRCs (similar to MPEG and other formats), which, along with framing, allow decoders to pick up in the middle of a stream with a minimum of delay.

* Suitable for archiving: FLAC is an open format, and there is no generation loss if you need to convert your data to another format in the future. In addition to the frame CRCs and MD5 signature, flac has a verify option that decodes the encoded stream in parallel with the encoding process and compares the result to the original, aborting with an error if there is a mismatch.

* Convenient CD archiving: FLAC has a ["cue sheet"](https://xiph.org/flac/format.html#def_CUESHEET) metadata block for storing a CD table of contents and all track and index points. For instance, you can rip a CD to a single file, then import the CD's extracted cue sheet while encoding to yield a single file representation of the entire CD. If your original CD is damaged, the cue sheet can be exported later in order to burn an exact copy.

* Error resistant: Because of FLAC's framing, stream errors limit the damage to the frame in which the error occurred, typically a small fraction of a second worth of data. Contrast this with some other lossless codecs, in which a single error destroys the remainder of the stream.

### What FLAC is not:

* Lossy. FLAC is intended for lossless compression only, as there are many good lossy formats already, such as Vorbis, MPC, and MP3 (see LAME for an excellent open-source implementation).

* DRM. There is no intention to add any copy prevention methods. Of course, we can't stop someone from encrypting a FLAC stream in another container (e.g. the way Apple encrypts AAC in MP4 with FairPlay), that is the choice of the user.

Latest Release : [Download](https://xiph.org/flac/)  
Using FLAC : https://xiph.org/flac/documentation_tasks.html

### Linux Install:

```
sudo apt-get install flac
sudo apt-get install faac faad flac lame libmad0 libmpcdec6 mppenc vorbis-tools wavpack 
```

</br>

This scripts allows one to edit the metadata of audio files using mutagen.

It takes the selected files and spits out a temporary csv file of the artist, album, and song title in that order. You then make your changes and write to the file to apply them. This script will not delete any info except for the stuff you overwrite. It simply updates the fields that are shown to the user.

If you want to edit other attributes of the file, then it's very easy to do so by changing a single variable yourself.

```python
#!/usr/bin/env python3

import sys
import os
import tempfile
import csv
import mutagen

# Options
editor = os.environ['EDITOR']
attrs = ['artist', 'album', 'title']
escape = '*'

songs = [] # List of mutagen objects
song_attrs = [] # Dictionaries containing attributes to be inspected

ff = sys.argv[1]
default_album_name = os.path.basename(os.path.dirname(os.path.abspath(ff)))
# Make sure mutagen uses the easy version, as
# it uses the normal one by default
extension = os.path.splitext(ff)[1] 
if extension == ".mp3":
    import mutagen.easyid3
    mut_init = mutagen.easyid3.EasyID3
elif extension == ".m4a":
    import mutagen.easymp4
    mut_init = mutagen.easymp4.EasyMP4
else:
    mut_init = mutagen.File

for f in sys.argv[1:]:
    songs.append(mut_init(f))
    song_attrs.append({})
    for attr in attrs:
        song_attrs[-1][attr] = songs[-1].get(attr, [''])[0]
        if not song_attrs[-1][attr]:
            if attr == 'artist':
                _attr = 'albumartist'
                song_attrs[-1][attr] = songs[-1].get(_attr, [''])[0]
            if attr == 'title':
                song_attrs[-1][attr] = os.path.splitext(f)[0]
            if attr == 'album':
                song_attrs[-1][attr] = default_album_name

with tempfile.NamedTemporaryFile('w+', suffix='.csv') as tmpf:
    csvwriter = csv.writer(tmpf, quoting=csv.QUOTE_NONE, escapechar=escape,
            skipinitialspace=True)
    csvwriter.writerows([row.values() for row in song_attrs])
    # Ensure that the file has been written to disk
    tmpf.flush()
    os.system("{} {}".format(editor, tmpf.name))
    tmpf.seek(0)
    csvreader = csv.reader(tmpf, quoting=csv.QUOTE_NONE,
            escapechar=escape, skipinitialspace=True)
    for song,row in zip(songs, csvreader):
        new_song_metadata = dict(zip(attrs, row))
        song.update(new_song_metadata)
        song.save()
```

