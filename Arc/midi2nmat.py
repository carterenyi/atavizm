import pandas as pd
import mido

def midi2nmat(path: str):
    """Converts MIDI file from raw messages to Note Matrix format"""
    mid = mido.MidiFile(path)
    tpb = mid.ticks_per_beat

    midiframe = pd.DataFrame(columns=["Voice", "Pitch", "Velocity", "Ticks"])

    for track in mid.tracks:
        for msg in track:
            if msg.type == 'note_on':
                df = pd.DataFrame({"Voice":msg.channel, "Pitch":msg.note, "Velocity":msg.velocity, "Ticks":msg.time},\
                                  index=[0])
                midiframe = midiframe.append(df, ignore_index=True)

    midiframe.loc[0,'Ticks'] = 0

    midiframe['Time'] = pd.Series(midiframe['Ticks'].cumsum()/tpb, index=midiframe.index)

    note_on = pd.DataFrame(midiframe[midiframe['Velocity'] != 0])
    note_off = pd.DataFrame(midiframe[midiframe['Velocity'] == 0])
    newdex = range(0,len(note_off))

    note_off = note_off.reset_index(drop=True)
    note_on = note_on.reset_index(drop=True)

    note_on['Duration'] = pd.Series(note_off['Time'] - note_on['Time'], index = note_on.index)

    return note_on[['Pitch', 'Time', 'Velocity', 'Voice', 'Duration']]

def _nmatPloy2Mono(nmat):
    """Turns Polyphonic MIDI File into Monophonic MIDI file"""
