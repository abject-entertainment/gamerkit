
function _Animator_tick()
{
	Animator.tick(_Animator.RATE / 1000);
}
function _Animator()
{
	this.animations = new Array();
	this.timer = window.setInterval(_Animator_tick, _Animator.RATE/1000);
	this.rate = 1.0;
}
_Animator.RATE = 33.3;
_Animator.prototype.tick = function(dTime)
{
	dTime *= this.rate;
	if (dTime > 0)
	{
		var cnt = this.animations.length;
		
		while (cnt--)
		{
			var anim = this.animations.shift();
			if (anim.update(dTime) != Animation.ANIM_DONE)
			{
				this.animations.push(anim);
			}
		}
	}
}
_Animator.prototype.setRate = function(newRate)
{ this.rate = newRate; }

_Animator.prototype.addAnimation = function(anim)
{
	if (anim instanceof Animation)
	{
		if (anim.rate == 0) anim.play();
		this.animations.push(anim);
	}
}

var Animator = new _Animator();
function Animation(obj)
{
	this.time = 0;
	this.rate = 0.0;
	this.tracks = new Object();
	this.target = obj;
}

Animation.ANIM_DONE = 'done';
Animation.ANIM_NOTDONE = 'continue';

Animation.prototype.play = function(play_rate)
{
	if (play_rate != undefined)
		this.rate = play_rate;
	else
		this.rate = 1.0;
		
	var maxTime = -1;
	for (var t in this.tracks)
	{
		if (maxTime == -1)
			maxTime = this.tracks[t].last.time;
		else if (this.tracks[t].last.time != maxTime)
			console.log("VARYING TRACK TIMES.  COULD BE A PROBLEM");
		t.recent = null;
	}
}

Animation.prototype.stop = function()
{
	this.play(0.0)
}

Animation.prototype.gotoAndPlay = function(t,r)
{
	this.time = t;
	this.play(r);
}

Animation.prototype.gotoAndStop = function(t)
{
	this.gotoAndPlay(t,0);
}

Animation.prototype.animateProperty = function(prop, startValue)
{
	var p = this.tracks[prop];
	
	if (p == null)
	{
		p = {prop:prop, first:null, last:null, maxTime:0, recent:null};
		p.first = {time:0, value:startValue, next:null};
		p.last = p.first;
	}
	else
	{
		p.first.value = startValue;
	}
	this.tracks[prop] = p;
}

Animation.prototype.addKeyframe = function(prop, t, v)
{
	if (t <= 0) return;
	
	var p = this.tracks[prop];
	if (p == null) return;

	var frame = p.first;
	
	while (frame)
	{
		if (frame.time == t)
		{
			frame.value = v;
			return;
		}
		
		if (frame.next == null ||
			frame.next.time > t)
		{
			break;
		}
		
		frame = frame.next;
	}
	
	var newf = {time:t, value:v, next:frame.next};
	frame.next = newf;
	
	if (frame == p.last)
	{
		p.last = newf;
		p.maxTime = newf.time;
	}
}

Animation.prototype.applyValue = function(prop, v, t)
{
	if (v != null && this.target != null)
	{
		if (v instanceof Function)
		{
			v.call(this.target, prop, this, t);
		}
		else if (this.target[prop] instanceof Function)
		{
			this.target[prop](v, this, t);
		}
		else
		{
			this.target[prop] = v;
		}
	}
}

Animation.prototype.update = function(deltaT)
{
	if (this.target == null || this.rate == 0) return Animation.ANIM_DONE;
	
	var oldTime = this.time;
	this.time += deltaT * this.rate;
	if (this.time != oldTime)
	{
		for (var prop in this.tracks)
		{
			var currProp = this.tracks[prop];
			var currTime = this.time % currProp.maxTime;
			var lastTime = oldTime % currProp.maxTime;

			var f = currProp.first;
			
			if (currProp.recent == null)
			{ // first update
				while (f)
				{
					if (f.next == null ||
						f.next.time > currTime)
					{
						break;
					}
					f = f.next;
				}
			}
			else
			{ // check for function triggers
				f = currProp.recent;
				
				while (f.time > currTime)
				{ // wrap around
					if (f.next == null)
					{
						f = currProp.first;
					}
					else
					{
						f = f.next;
						this.applyValue(prop, f.value, f.time);
						if (this.rate == 0)
						{
							this.time = f.time;
							break;
						}
					}
				}
				
				while (f)
				{
					if (f.next == null ||
						f.next.time > currTime)
					{
						break;
					}
					f = f.next;
					this.applyValue(prop, f.value, f.time);
					if (this.rate == 0)
					{
						this.time = f.time;
						break;
					}
				}
			}
			
			// now f is before and f.next is after
			if (f && f.next)
			{
				var final_v = null;
				if (typeof(f.value) == 'number' &&
					typeof(f.next.value) == 'number')
				{
					// interpolate numbers
					final_v = ((f.next.value - f.value) *
						((currTime - f.time) / (f.next.time - f.time))) + 
						f.value;
				}
				else if (f != currProp.recent)
				{
					final_v = f.value;
				}
				else
				{
					continue;
				}

				this.applyValue(prop, final_v, currTime);				
				
				currProp.recent = f;
			}
		}
	}
	
	if (this.rate == 0) return Animation.ANIM_DONE;
	return Animation.ANIM_NOTDONE;
}
