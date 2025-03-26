using DAA.Shared.Utilities;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Shared.Certificates
{
    public class CertificateParser
    {
        public static ParseResult DecodeCert(X509Certificate2 _cert)
        {
            ParseResult result = new ParseResult();
            string certSubject = _cert.Subject;

            result.IssuerName = GetCertIssuerName(_cert).Split(' ')[0];
            result.Success = true;

            if (DateTime.Now > _cert.NotAfter || DateTime.Now < _cert.NotBefore)
            {
                result.Errors.Add("Certificate is out of date");
                result.Success = false;
                return result;
            }

            string[] subjectParts;
            string tempEgnString = "";
            string tempEikString = "";

            subjectParts = _cert.Subject.Split(new string[] { ", " }, StringSplitOptions.RemoveEmptyEntries);

            // Check for new European Encoding first
            if (subjectParts.Any(x => x.Contains("SERIALNUMBER")))
            {
                Dictionary<string, string> subjectPairs = new Dictionary<string, string>();

                foreach (var item in subjectParts)
                {
                    string[] split = item.Split('=');
                    subjectPairs.Add(split[0], split[1]);
                }

                try
                {
                    result.HolderName = subjectPairs["CN"];
                    result.HolderEGN = subjectPairs["SERIALNUMBER"].Split('-')[1];
                    result.HolderEmail = subjectPairs["E"];

                    //Check for EIK
                    if (subjectPairs.ContainsKey("OID.2.5.4.97"))
                    {
                        result.HolderEIK = subjectPairs["OID.2.5.4.97"].Split('-')[1];
                    }

                    if (!CheckEgn(result.HolderEGN))
                    {
                        result.Errors.Add("Invalid EGN");
                        result.Success = false;
                    }
                }
                catch (Exception x)
                {
                    result.Success = false;
                    result.Errors.Add(x.Message);
                }

                return result;
            }
            else
            {
                switch (result.IssuerName)
                {
                    case CertificateIssuer.Evrotrust:
                        result.HolderName = subjectParts.Where(w => w.Contains("CN=")).FirstOrDefault().Split('=')[1];

                        tempEgnString = subjectParts.Where(w => w.Contains("SERIALNUMBER=PNOBG")).FirstOrDefault();

                        if (!string.IsNullOrWhiteSpace(tempEgnString))
                        {
                            result.HolderEGN = tempEgnString.Split('-')[1];

                            if (!CheckEgn(result.HolderEGN))
                            {
                                throw new Exception("Invalid EGN string");
                            }
                        }

                        tempEikString = subjectParts.Where(w => w.Contains("OID.2.5.4.97=NTRBG")).FirstOrDefault();

                        if (!string.IsNullOrWhiteSpace(tempEikString))
                        {
                            result.HolderEIK = tempEikString.Split('-')[1];
                        }
                        break;
                    case CertificateIssuer.eSign:
                    case CertificateIssuer.SEP:
                        result.HolderName = subjectParts.Where(w => w.Contains("CN=")).FirstOrDefault().Split('=')[1];

                        tempEgnString = subjectParts.Where(w => w.Contains("OID.0.9.2342.19200300.100.1.1=EGN")).FirstOrDefault();

                        if (!string.IsNullOrWhiteSpace(tempEgnString))
                        {
                            result.HolderEGN = tempEgnString.Split('=')[1].Substring(3); ;

                            if (!CheckEgn(result.HolderEGN))
                            {
                                throw new Exception("Invalid EGN string");
                            }
                        }

                        tempEikString = subjectParts.Where(w => w.Contains("OU=EIK")).FirstOrDefault();

                        if (!string.IsNullOrWhiteSpace(tempEikString))
                        {
                            result.HolderEIK = tempEikString.Split('=')[1].Substring(3);
                        }
                        break;

                    case CertificateIssuer.Spektar:
                        result.HolderName = subjectParts.Where(w => w.Contains("CN=")).FirstOrDefault().Split('=')[1];
                        result.HolderEIK = subjectParts.Where(w => w.Contains("OU=")).FirstOrDefault().Split('=')[1].Split(':')[1];
                        result.HolderEIK = new string(result.HolderEIK.TakeWhile(char.IsDigit).ToArray());

                        try
                        {
                            result.HolderEGN = subjectParts.Where(w => w.Contains("T=")).FirstOrDefault().Split('=')[1]
                                                    .Split(',').Where(w => w.Contains("EGN:")).FirstOrDefault().Split(':')[1].Substring(0, 10);
                        }
                        catch (NullReferenceException)
                        {
                            int holderEGNPos = certSubject.IndexOf("EGN:");
                            if (holderEGNPos > 0)
                            {
                                result.HolderEGN = certSubject.Substring(holderEGNPos + 4, 10);
                                if (!CheckEgn(result.HolderEGN))
                                {
                                    result.Errors.Add("Invalid EGN string");
                                    result.Success = false;
                                }
                            }
                            else
                            {
                                result.Errors.Add("No EGN string");
                                result.Success = false;
                            }
                        }
                        break;
                    case CertificateIssuer.iNotary:
                        subjectParts = _cert.Subject.Split(new string[] { " + " }, StringSplitOptions.RemoveEmptyEntries);

                        result.HolderName = subjectParts.Where(w => w.Contains("CN=")).FirstOrDefault().Split('=')[1];
                        result.HolderName = result.HolderName.Replace('"', ' ').Trim();
                        var q = from X509Extension e in _cert.Extensions
                                where e.Oid.Value == "2.5.29.17"
                                select e.Format(true);

                        string[] dalines = q.FirstOrDefault().Split(new string[] { "\r\n" }, StringSplitOptions.RemoveEmptyEntries);
                        Hashtable daAttributes = new Hashtable();
                        foreach (string line in dalines)
                        {
                            string[] attr = line.Trim().Split('=');
                            daAttributes.Add(attr[0], attr[1]);
                        }
                        result.HolderEGN = (string)daAttributes["OID.2.5.4.3.100.1.1"];

                        if (string.IsNullOrWhiteSpace(result.HolderEGN) && !result.HolderEGN.Contains("90909090") && !CheckEgn(result.HolderEGN))
                        {
                            result.Errors.Add("Invalid EGN string");
                            result.Success = false;
                        }

                        int EIKpos = certSubject.IndexOf("OID.2.5.4.10.100.1.1");
                        if (EIKpos >= 0)
                        {
                            result.HolderEIK = certSubject.Substring(EIKpos + 21, certSubject.IndexOf(" ", EIKpos) - EIKpos - 21);
                        }

                        break;
                    case CertificateIssuer.BTrust:
                        try
                        {
                            result.HolderName = subjectParts.Where(w => w.Contains("CN=")).FirstOrDefault().Split('=')[1];

                            tempEikString = subjectParts.Where(w => w.Contains("OU=")).FirstOrDefault();
                            if (!string.IsNullOrWhiteSpace(tempEikString))
                            {
                                result.HolderEIK = tempEikString.Split('=')[1].Split(':')[1];
                            }

                            tempEgnString = subjectParts.Where(w => w.Contains("S=")).FirstOrDefault();

                            if (!string.IsNullOrWhiteSpace(tempEgnString))
                            {
                                result.HolderEGN = tempEgnString.Split('=')[1].Split(',').Where(w => w.Contains("EGN:")).FirstOrDefault().Split(':')[1].Substring(0, 10);
                            }
                        }
                        catch (NullReferenceException)
                        {
                            int holderEGNPos = certSubject.IndexOf("EGN:");

                            if (holderEGNPos > 0)
                            {
                                result.HolderEGN = certSubject.Substring(holderEGNPos + 4, 10);
                                if (!CheckEgn(result.HolderEGN))
                                {
                                    result.Errors.Add("Invalid EGN string");
                                    result.Success = false;
                                }
                            }
                            else
                            {
                                holderEGNPos = certSubject.IndexOf("PID:");
                                if (holderEGNPos > 0)
                                {
                                    result.HolderEGN = certSubject.Substring(holderEGNPos + 4, 10);
                                    if (!(CheckLNCH(result.HolderEGN) || CheckEgn(result.HolderEGN)))
                                    {
                                        result.Errors.Add("Invalid EGN/LNCH string");
                                        result.Success = false;
                                    }
                                }
                                else
                                {
                                    result.Success = false;
                                }
                            }
                        }

                        if (!result.HolderEGN.StartsWith("90909090") && !(CheckLNCH(result.HolderEGN) || CheckEgn(result.HolderEGN)))
                        {
                            result.Errors.Add("Invalid EGN/LNCH string");
                            result.Success = false;
                        }

                        if (!string.IsNullOrWhiteSpace(tempEikString))
                        {
                            result.HolderEIK = tempEikString.Split('=')[1].Split(':')[1];
                        }
                        break;

                    case CertificateIssuer.StampIT:
                        result.HolderName = subjectParts.Where(w => w.Contains("CN=")).FirstOrDefault().Split('=')[1];
                        string sPart = subjectParts.Where(w => w.Contains("S=")).FirstOrDefault().Split('=')[1];

                        try
                        {
                            result.HolderEGN = sPart.Split(',').Where(w => w.Contains("EGN:")).FirstOrDefault().Split(':')[1].Substring(0, 10);
                            result.HolderEIK = sPart.Split(',').Where(w => w.Contains("B:")).FirstOrDefault().Split(':')[1];
                        }
                        catch (NullReferenceException)
                        {
                            result.Success = false;
                        }

                        if (!CheckEgn(result.HolderEGN))
                        {
                            result.Errors.Add("Invalid EGN/LNCH string");
                            result.Success = false;
                        }
                        break;
                    default:
                        result.Errors.Add("Unknown issuer");
                        result.Success = false;
                        break;
                }
            }

            return result;
        }

        private static string GetCertIssuerName(X509Certificate2 _cert)
        {
            if (_cert == null) return "";
            string issuerName = _cert.Issuer;

            string[] nameParts = { "CN=" };
            string cn = "";
            char delimiter = '\0';

            if (issuerName.Contains("InfoNotary")) delimiter = '+';
            if (issuerName.Contains("B-Trust")) delimiter = ',';
            if (issuerName.Contains("StampIT")) delimiter = ',';
            if (issuerName.Contains("Spektar")) delimiter = ',';
            if (issuerName.Contains("eSign")) delimiter = ',';
            if (issuerName.Contains("SEP")) delimiter = ',';
            if (issuerName.Contains("Evrotrust")) delimiter = ',';

            nameParts = _cert.Issuer.Split(delimiter);
            cn = nameParts.Where(w => w.Contains("CN=")).FirstOrDefault().Split('=')[1];

            return cn;
        }

        private static bool CheckEgn(string egn)
        {
            return PersonIdentification.CheckEgn(egn);
        }

        private static bool CheckLNCH(string lnch)
        {
            return PersonIdentification.CheckLNCH(lnch);
        }
    }
}
