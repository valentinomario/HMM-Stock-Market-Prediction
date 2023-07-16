function savefig(name)
% savefig(nameString)
% Usage: open the figure, then go to the command window and type
%       >> savefig('name')
%        as string, without extension
%
    f = gcf;
    f.Position(3:4) = [850 500];
    fil = strcat('out_figs\', name);
    print(fil, '-depsc', '-vector')
