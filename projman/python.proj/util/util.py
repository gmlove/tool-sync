import re


def PrintObjectProperties(object, spacing=25):  
        propList = [prop for prop in dir(object) if (not prop.startswith('_') and not callable(getattr(object, prop))) ]
        print("[%s's Property List:]:"%str(object) )
        print("\n".join(["%s %s %s" %
                (prop.ljust(spacing),str(type(getattr(object, prop))).ljust(spacing), (str(type(getattr(object, prop)))=="<type 'property'>" and getattr(object, prop).__doc__) or getattr(object, prop))
                for prop in propList]) )

def PrintObjectMethods(object, spacing=25):  
        methodList = [method for method in dir(object) if (not method.startswith('_') and callable(getattr(object, method))) ]
        print( "[%s's Methods List:]:"%str(object) )
        print("\n".join(["%s %s" %
                (method.ljust(spacing), getattr(object, method).__doc__)
                for method in methodList]) )

def VarNameConvert(name):
        # TODO: re.match("[^_]+","_123__")] why true?
        if name.find("_") == -1:
                words = []
                index = 0
                for i in range(len(name)):
                        if name[i].isupper() and i != 0:
                                words.append(name[index:i])
                                index = i
                words.append(name[index:len(name)])
                return "_".join(words).lower()
        else:
                words = re.split("_", name)
                ret = ""
                for i in range(len(words)):
                        w = words[i]
                        if i == 0:
                                ret += w.lower()
                        else:
                                ret += w[0].upper() + w[1:].lower()
                return ret


if __name__ == "__main__":
        print VarNameConvert("varName")
        print VarNameConvert("AVarName")
        print VarNameConvert("A123VarNM")
        print VarNameConvert("time_var_a_time")
        print VarNameConvert("TIme_var_A_TIME")
        print VarNameConvert("a")
        print VarNameConvert("A")

