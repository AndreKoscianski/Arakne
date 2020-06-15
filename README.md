# Arakne
A Petri-Net Tool.

Development begun during the Coronavirus isolation period, March/2020. 

Implemented using Lazarus: just compile to get a standalone.


2020/mar/24, edit unmarked P/T nets, load and save the essential .PNML information.

2020/apr/10, P/T with marking, basic playing. 

2020/jun/07, now hierarchical PN (thanks Moacir G. Brito for the ideas concerning data structures), load/save using CSV (PNML sucks, sorry). todo: redo petri player (still not hierarchical), finish calculation of invariants.

2020/jun/14, petri player now supports hierarchy. 
Also, cloned places. Also, inhibitory arcs.
Edit menu=align and distribute elements.
Calculation of invariants is almost ok (including assembling of sub-nets); found a glitch with inhibitory arcs.
Inhibitory arcs receive weight = 0 in this calculation, a non-standard procedure (but it seems to me the right way to handle it: if an inhibitory arc is not active, then it does nothing; if active, it does not consume a token).
