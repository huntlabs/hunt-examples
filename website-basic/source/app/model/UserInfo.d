module app.model.UserInfo;

import hunt.entity;


@Table("userinfo", "hunt_")
class UserInfo : Model {

    mixin MakeModel;

    @AutoIncrement 
    @PrimaryKey 
    int id;

    @Column("nickname")
    @Length(0,50)
    string nickName;
    
    @Max(150)
    int age;

    ubyte[] image;

    @Transient
    string sex;

    override void onInitialized() {
        
    }
}