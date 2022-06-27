package unical.dimes.uptocloud.support;


import lombok.experimental.UtilityClass;

import java.text.Normalizer;

@UtilityClass
public class Utils {

    public static String unaccent(String src) {
        return Normalizer
                .normalize(src, Normalizer.Form.NFD)
                .replaceAll("[^\\p{ASCII}]", "").trim();
    }
}
