package org.egov.pg.service.gateways.sbi;

import java.util.Base64;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import org.springframework.stereotype.Service;

@Service
public class AES256Bit {

	private static String res;
	private static byte[] iv;

	static {
		AES256Bit.iv = null;
	}

	public static String encrypt(final String s, final SecretKeySpec secretkeyspec) {
		String s2 = "";
		try {
			final Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
			final IvParameterSpec ivparameterspec = new IvParameterSpec(AES256Bit.iv);
			cipher.init(1, secretkeyspec, ivparameterspec);
			final byte[] abyte0 = cipher.doFinal(s.getBytes("UTF-8"));
			s2 = Base64.getEncoder().encodeToString(abyte0);

		} catch (Exception ex) {
		}
		return s2;
	}

	public static String decrypt(final String s, final SecretKeySpec secretkeyspec) {
		String s2 = "";
		try {
			final Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
			final IvParameterSpec ivparameterspec = new IvParameterSpec(AES256Bit.iv);
			cipher.init(2, secretkeyspec, ivparameterspec);
			byte[] abyte0 = Base64.getDecoder().decode(s);
			final byte[] abyte2 = cipher.doFinal(abyte0);
			s2 = new String(abyte2);
		} catch (Exception ex) {
		}
		return s2;
	}

	public static String asHex(final byte[] abyte0) {
		final StringBuffer stringbuffer = new StringBuffer();
		for (int i = 0; i < abyte0.length; ++i) {
			stringbuffer.append(Integer.toHexString(256 + (abyte0[i] & 0xFF)).substring(1));
		}
		return stringbuffer.toString();
	}

	public static SecretKeySpec readKeyBytes(final String s) {
		SecretKeySpec secretkeyspec = null;
		int i = 0;
		final byte[] abyte0 = new byte[16];
		try {
			AES256Bit.res = s;
			final String s2 = AES256Bit.res;
			final byte[] abyte2 = s2.getBytes("UTF8");
			final byte[] abyte3 = s2.getBytes();
			int j = 0;
			Label_0065_Outer: while (j < 16) {
				boolean flag1 = false;
				while (true) {
					while (i < abyte2.length) {
						if (j != i) {
							continue Label_0065_Outer;
						}
						flag1 = true;
						if (flag1) {
							abyte0[j] = abyte2[j];
						}
						++j;
						++i;
						continue Label_0065_Outer;
					}
					continue;
				}
			}
			AES256Bit.iv = abyte0;
			secretkeyspec = new SecretKeySpec(abyte0, "AES");
		} catch (Exception ex) {
		}
		return secretkeyspec;
	}

	public static String byteToHex(final byte byte0) {
		final char[] ac = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
		final char[] ac2 = { ac[byte0 >> 4 & 0xF], ac[byte0 & 0xF] };
		return new String(ac2);
	}

	public static String generateNewKey() {
		String newKey = null;
		try {
			final KeyGenerator kgen = KeyGenerator.getInstance("AES");
			kgen.init(256);
			final SecretKey skey = kgen.generateKey();
			final byte[] raw = skey.getEncoded();
			newKey = Base64.getEncoder().encodeToString(raw);
			newKey = newKey.replace("+", "/");
		} catch (Exception ex) {
		}
		return newKey;
	}

}
