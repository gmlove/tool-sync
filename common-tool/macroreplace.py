"""
        This tool is used to expand MACROS.
        It handles all the files named like '*.m' in the current directory and sub directories 
and output files named like '*'(You guess it right. Just remove the '.m' suffix.) in the same directory as the '*.m' file.
        You should write a file which contains MACROS, named "macros" in the current directory.
        The pattern of the MACROS is simple, like: MACRO = expanded macro, and delimited by line seperator.

@author: Kyle
@TODO:  support multi-line MACROS
        support expand one .m file to multiple files as the macros file said(done)
        support MACROS inheritance(done)
        support configured output directory
"""


import os
import sys
import re
import setting

log = setting.logger


class MacroExpander:

        file="macros"
        default_key='default'
        parent_key='parent'
        template_file_key='template'


        def __init__(self):
                self._m_file = MacroExpander.file
                self._files_to_replace = []
                self._templates = {}

        def findFilesToReplace(self):
                for i in os.walk("."):
                        for f in i[2]:
                                if re.match(r".*\.m$", f) != None:
                                        af = os.path.join(i[0],f)
                                        log.info("template file %s found."%(af,))
                                        self._files_to_replace.append(af)
                log.info("end find files.")


        def parseMacrosFile(self):
                file = open(self._m_file, "r")
                line = file.readline()
                nlines = 1
                current_section=MacroExpander.default_key
                while line != '':
                        if re.match(r"^\s+$",line) != None:
                                line = file.readline()
                                nlines += 1
                                continue
                        sbegin = line.find('[')
                        send = line.find(']')
                        log.debug("%s\t%s\t%s"%(current_section, nlines, line))
                        if sbegin == -1 or send == -1:
                                n, line, m = self._parseMacroLine(line, file)
                                nlines += n
                                self._templates[current_section] = m
                                log.info("add macro: %s to template %s" % (m, current_section))
                                if line.find('[') == -1 and line != '':
                                        log.error("error in macros file. line: %s, value: %s"%(nlines, line))
                                        file.close()
                                        sys.exit(1)
                        else:
                                current_section=line[sbegin+1:send].strip()
                                if current_section == '':
                                        log.error("error in macros file. line: %s, value: %s"%(nlines, line))
                                        file.close()
                                        sys.exit(1)
                                line = file.readline()
                file.close()

                if MacroExpander.template_file_key not in self._templates[MacroExpander.default_key]:
                        self._templates[MacroExpander.default_key][MacroExpander.template_file_key] = '.*'

                log.info("end parse macros.")


        def _parseMacroLine(self, line, file):
                nlines = 0
                macros = {}
                while line != '':
                        if re.match(r"^\s+$",line) != None:
                                line = file.readline()
                                nlines += 1
                                continue
                        sep=line.find("=")
                        if sep == -1:
                                return nlines, line, macros
                        key = line[0:sep].strip()
                        macros[key] = line[sep+1:].strip()
                        log.debug("found macros: %s:%s"%(key, macros[key]))
                        line = file.readline()
                return nlines, line, macros

        def _expandTemplates(self):
                for key in self._templates:
                        if not MacroExpander.parent_key in self._templates[key]:
                                self._recurExpand(key)
                log.info("expanded macros: %s" % (self._templates,))


        def _recurExpand(self, sec):
                children = self._childrenSections(sec)
                for s in children:
                        self._expandTemplate(self._templates[sec], self._templates[s])
                        self._recurExpand(s) 



        def _childrenSections(self, section):
                children = []
                for key in self._templates:
                        temp = self._templates[key]
                        if MacroExpander.parent_key in temp and temp[MacroExpander.parent_key] == section:
                                children.append(key)
                return children

        def _expandTemplate(self, t1, t2):
                for key in t1:
                        if key not in t2:
                                t2[key] = t1[key]

        def _checkTemplateTree(self):
                #TODO
                pass
                   

        def _recurGetMacro(self, section, key):
                if not section in self._templates:
                        log.warn("section %s not in templates %s." % (section, self._templates.keys()))
                        return ""
                if key in self._templates[section]:
                        return self._templates[section][key]

                template = self._templates[section]

                #this is used to avoid dead recursive parent
                maxDepth = 10
                nDepth = 0
                while MacroExpander.parent_key in template:
                        parent = template[MacroExpander.parent_key]
                        if parent not in self._templates:
                                log.warn("section %s not in templates %s." % (section, self._templates.keys()))
                                return ""
                        template = self._templates[parent]
                        if key in template:
                                return template[key]

                        nDepth += 1
                        if nDepth == maxDepth:
                                log.error("maxDepth %s reached when find key %s in section %s. may have a " % (maxDepth, key, section))
                                sys.exit(1)

                                




        def macroReplace(self, str, section):
                if section not in self._templates:
                        log.warn("section %s not in templates $s." %(section, self._templates.keys()))
                        return
                for key in self._templates[section]:
                        if key in [MacroExpander.default_key, MacroExpander.parent_key, MacroExpander.template_file_key]:
                                continue
                        #TODO this is not safe when meet recursive MACROS in the str
                        str = str.replace(key, self._templates[section][key])
                return str

        def getLeafs(self):
                leafs = []
                for se in self._templates:
                        ch = self._childrenSections(se)
                        if len(ch) == 0:
                                leafs.append(se)
                if len(leafs) == 0:
                        leafs.append(MacroExpander.default_key)
                log.info("get leafs: %s"%(leafs,))
                return leafs


        def macroReplaceFiles(self):
                leafs = self.getLeafs()
                for section in leafs:
                        filename = section
                        template = self._templates[section]
                        for f in self._files_to_replace:
                                if re.match(template[MacroExpander.template_file_key], f) == None:
                                        continue
                                file = open(f, "r")
                                #TODO handle file name.
                                #dest_f = f[0:f.rfind('.')]
                                dest_f = os.path.dirname(f) + "/" + filename
                                if os.path.exists(dest_f):
                                        log.info("will overwrite file: %s"%(dest_f,))
                                else:
                                        log.info("will generate file: %s"%(dest_f,))
                                dest_f = open(dest_f, "w")
                                line = file.readline()
                                while line != '':
                                        line1 = self.macroReplace(line, section)
                                        while  line1 != line:
                                                line = line1
                                                line1 = self.macroReplace(line, section)
                                        dest_f.write(line)
                                        line = file.readline()
                                file.close()
                                dest_f.close()

        
        def run(self):
                self.findFilesToReplace()
                self.parseMacrosFile()
                self._expandTemplates()
                self.macroReplaceFiles()

if __name__ == "__main__":
        MacroExpander().run()


