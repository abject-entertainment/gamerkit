

function Popup(title, toRect, fromPoint)
{
	this.outer = document.createElement("DIV");
	this.outer.className = "UI_popup_outer";

	this.title = document.createElement("DIV");
	this.title.className = "UI_popup_title";
	this.title.innerText = title;
		
	this.close = document.createElement("DIV");
	this.close.className = "UI_popup_close";
	this.close.innerHTML = "&nbsp;"
	this.close.popup = this;
	this.close.onclick = function() { Animator.addAnimation(this.popup.outAnim); }
	
	this.inner = document.createElement("DIV");
	this.inner.className = "UI_popup_inner";

	this.outer.appendChild(this.inner);
	this.outer.appendChild(this.close);
	this.outer.appendChild(this.title);
	
	this.startAnimating = function(p,a,t)
	{
		if (p == 'close')
		{
			this.inner.style.display = "none";
			this.close.style.display = "none";
			this.title.style.display = "none";
		}
	}
	this.doneAnimating = function(p,a,t)
	{
		if (p == 'open')
		{
			this.outer.style.left = this.targetRect.x;
			this.outer.style.top = this.targetRect.y;
			this.outer.style.width = this.targetRect.w;
			this.outer.style.height = this.targetRect.h;
			
			this.inner.style.display = "inline-block";
			this.close.style.display = "inline-block";
			this.title.style.display = "inline-block";
			this.inAnim.stop();
			var d = document.getElementById("scroll_lock");
			if (d)
			{ d.style.overflow = "hidden"; }
		}
		else if (p == 'close')
		{
			this.outAnim.stop();
			this.outer.parentNode.removeChild(this.outer);
			var d = document.getElementById("scroll_lock");
			if (d)
			{ d.style.overflow = "auto"; }
		}
	}
	
	if (fromPoint != undefined)
	{
		this.inner.style.display = "none";
		this.close.style.display = "none";
		this.title.style.display = "none";
		
		this.targetRect = toRect;
		this.startPos = fromPoint;
		
		this.inAnim = new Animation(this);

		this.inAnim.animateProperty("open",this.startAnimating);
		this.inAnim.addKeyframe("open",1.0,null);
		this.inAnim.addKeyframe("open",2.0,this.doneAnimating);

		this.inAnim.animateProperty("animateIn",0);
		this.inAnim.addKeyframe("animateIn",1.0,1.1);
		this.inAnim.addKeyframe("animateIn",2.0,1.0);
		
		this.outAnim = new Animation(this);

		this.outAnim.animateProperty("close",this.startAnimating);
		this.outAnim.addKeyframe("close",1.0,null);
		this.outAnim.addKeyframe("close",2.0,this.doneAnimating);

		this.outAnim.animateProperty("animateIn",1.0);
		this.outAnim.addKeyframe("animateIn",1.0,1.1);
		this.outAnim.addKeyframe("animateIn",2.0,0.0);
		
		Animator.addAnimation(this.inAnim);
	}
	else
	{
		this.inner.style.display = "block";
		this.outer.style.top = toRect.y;
		this.outer.style.left = toRect.x;
		this.outer.style.width = toRect.w;
		this.outer.style.height = toRect.h;
	}
	
	this.animateIn = function(v,a,t)
	{
		this.outer.style.left = Math.floor(((this.targetRect.x - this.startPos.x) * v) + this.startPos.x);
		this.outer.style.top = Math.floor(((this.targetRect.y - this.startPos.y) * v) + this.startPos.y);
		
		this.outer.style.width = Math.floor(this.targetRect.w * v);
		this.outer.style.height = Math.floor(this.targetRect.h * v);
	}
	
	document.body.appendChild(this.outer);
}