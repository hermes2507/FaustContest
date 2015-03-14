
/*
<VoiceSynth V1.0, a voice synthesizer based on formant filters>
Copyright (C) <2015>  <Santiago Rentería>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


import("filter.lib");
import("effect.lib");
import("oscillator.lib");
import("music.lib");


declare name        "envelop";
declare version     "1.0";
declare author      "Grame";
declare license     "BSD";
declare copyright   "(c) GRAME 2006";

//-------------------------------------------------
//      ADSR Envelop Generator
//      The 'state' of the envelop generator is
//      defined by a phase signal p2 allowing to
//      distinguish the attack and the decay-sustain
//      phases, and the envelop signal y itself.
//-------------------------------------------------

envelop(a,d,s,r,t) = adsr ~ (_,_) : !,_                     // The 2 'state' signal are feedback
    with {
        adsr (p2,y) = (t>0) & (p2|(y>=1)),                  // p2 = decay-sustain phase
                      y + p1*a - (p2&(y>s))*d*y - p3*r*y    // y  = envelop signal
        with {
            p1 = (p2==0) & (t>0) & (y<1);                   // p1 = attack phase
            p3 = (t<=0) & (y>0);                            // p3 = release phase
        };
    };


attack  = 1.0/(SR*nentry("Attack[style: knob]", 60, 1, 1000, 1)/1000);
decay   = nentry("Decay[style: knob]", 2, 1, 100, 0.1)/100000;
sustain = nentry("Sustain[style: knob]", 10, 1, 100, 0.1)/100;
release = nentry("Release[style: knob]", 10, 1, 100, 0.1)/100000;

//////////////////////////////////////////////////////////////////////////////

Formant(fx,cont) = resonbp(fx,B,1)
with{
	B = vslider("Filter Q",100,1,100,0.1);
};
masterGain = vslider("Gain",0.3,0,1,0.01);
freq = vslider("Frequency ",100,20,3500,0.01);
oscil(freq) = sawtooth(freq+1.5*osc(6));

vowel = nentry("Vowel",1,0,2,1);

yA = select3(vowel,280,400,710);
yB = select3(vowel,2250,1920,1100);
yC = select3(vowel,2890,2650,2450);

formants = hgroup("Formants",Formant(yA,1):Formant(yB,2):Formant(yC,3));
voice = hgroup("Voice Synth",button("Play"): hgroup("ADSR Envelope",envelop(attack, decay, sustain, release))*(oscil(freq))*masterGain:formants);

process = voice<:_,_;
