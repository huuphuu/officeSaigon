// JScript File

function id(id)
{
    return document.getElementById(id);
}

function isEmail(email)
{
    var filter = /^([a-zA-Z0-9_\.\-'])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;		
    return filter.test(email);
}

function isNumeric(s){
	var filter = /^[0-9]{1,4}$/;
	return filter.test(s);
}