# RWAPSSF

## Problem

1. ไม่มีใครอยากจะเลือกก่อน เพราะว่ากลัวถูกอีกคนทำ front-running (การได้ประโยชน์จากการรู้ล่วงหน้าว่าคนหนึ่งเลือกอะไร)
2. ยากต่อการจะรู้ว่าเราใคร account ไหนเป็น idx ที่ 0 หรือ 1
3. เงินของ player 0 อาจถูกล๊อกไว้ ถ้าไม่มี player 1 มาลงขันต่อ
4. กรณีได้ player ทั้ง 2 แล้ว แต่มีเพียง player เดียวที่ลง choice มา แต่อีก player ไม่ยอมเรียก input function เพื่อส่ง choice มาให้ smart contract ได้ตัดสินแพ้ ชนะ เสมอ เช่นนี้ทำให้เงิน ETH ของทุกคนที่ลงขันมาถูกล็อกไว้โดยไม่มีใครถอนออกมาได้
5. ทำยังไงให้ contract นี้(มีการ transact กับมัน) ได้ในหลายๆ รอบโดยที่ไม่ต้องมีการ deploy ใหม่เสมอในทุกๆครั้งที่ต้องการเล่น
6. เล่น

## Solution

1. Use commitment to protect front-running
2. Use account address instead idx 0 or 1
3. Use timer to protect lock
4. Restart game when game finish
