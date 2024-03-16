Fields={
  tags: function (tags){
    var options=[];
    var val="";
    tags.restrictions.options[2].forEach ((tag) =>{
      options.push(tag[1]);
      if(tags.val.includes(tag[0])) {val=val + tag[1] + " "}
    })
    return [tags.label(),input({name: "tags", value: val})]; 
  }

}
