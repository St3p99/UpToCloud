package unical.dimes.uptocloud.support.exception;

import lombok.ToString;
import lombok.Getter;

@ToString
@Getter
public class UniqueKeyViolationException extends Exception{
    private String msg;

    public UniqueKeyViolationException(String msg){
        this.msg = msg;
    }

}
