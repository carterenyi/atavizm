import pandas as pd
import mido

def midi2nmat(path):
    """Returns a Note Matrix from a given MIDI files"""
    
    assert (type(path) is str), "Filepath must be a string: %r" % path
    mid = mido.MidiFile(path)
    tpb = mid.ticks_per_beat

    midiframe = pd.DataFrame(columns=["Type", "Voice", "Pitch", "Velocity", "Ticks"])

    for track in mid.tracks:
        for msg in track:
            if msg.type == "note_on":
                df = pd.DataFrame({"Type":msg.type, "Voice":msg.channel, "Pitch":msg.note, "Velocity":msg.velocity, "Ticks":msg.time},\
                              index=[0])
            else:
                df = pd.DataFrame({"Type":msg.type, "Ticks":msg.time},\
                              index=[0])
            midiframe = midiframe.append(df, ignore_index=True)

    midiframe["Time"] = pd.Series(midiframe["Ticks"].cumsum() / tpb, index=midiframe.index)

    note_on = midiframe.loc[(midiframe["Velocity"] != 0) & (midiframe["Type"] == "note_on")]
    note_off = midiframe.loc[(midiframe["Velocity"] == 0) & (midiframe["Type"] == "note_on")]
    newdex = range(0,len(note_off))

    note_off = note_off.reset_index(drop=True)
    note_on = note_on.reset_index(drop=True)

    note_on["Duration"] = pd.Series(note_off["Time"] - note_on["Time"], index = note_on.index)

    return note_on[["Pitch", "Time", "Velocity", "Voice", "Duration"]]
    