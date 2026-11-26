function golden = golden_harness(mode, golden_file)
% GOLDEN_HARNESS  Capture or replay golden outputs for Stage-2 readability checks.
%   golden = golden_harness('capture', golden_file)
%   golden = golden_harness('replay', golden_file)
%
%   TEMPLATE -- replace the entry-point blocks below with this repo's own.
%   Everything outside those blocks carries over unchanged.
%
%   Calls entry points directly (never through the top-level driver script,
%   which typically uses rng('shuffle') on some paths) under an explicit
%   rng(cfg.seed), and either saves their outputs to GOLDEN_FILE ('capture')
%   or reloads GOLDEN_FILE and asserts isequal against a fresh run ('replay').
%
%   Entry points, by tranche (docs/repo-cleanup.md sections 1 and 4.2):
%     <tranche>   <functions>
%
%   Not covered: <files with no callable entry point -- a script whose logic
%   lives in local functions. Restructuring it is Stage 3, so that tranche's
%   Stage-2 edits are verified by pattern check only.>
%
% Inputs
%   mode         'capture' or 'replay'
%   golden_file  path to a .mat file to write to / read from
% Output
%   golden  struct of all entry-point outputs (as captured or as freshly
%           computed, depending on mode)
%
% See also CANON, CHECK_STAGE1

setup();
cfg = config();

% -------------------------------------------------------------------------
% Entry points. One block per function. Rules:
%   * rng(cfg.seed) immediately before each, so blocks are order-independent.
%   * Store a checksum or a size vector, never the whole array -- keeps the
%     golden .mat small and the isequal comparison fast.
%   * Reduce with an explicit 'all'. sum() over a cell array from cellfun
%     collapses only ONE dimension and silently returns a row vector.
%   * Gate toolbox-dependent blocks on exist(...) and warn, don't error.
% -------------------------------------------------------------------------

grid_sum = @(C) sum(cellfun(@(x) sum(x(:)), C), 'all');   %#ok<NASGU> % if needed

rng(cfg.seed);
% out = my_entry_point(cfg, ...);
% golden.my_entry_point_checksum = sum(out(:));
% golden.my_entry_point_size     = size(out);

% --- toolbox-gated block ---
if exist('dlnetwork', 'file') == 2
    rng(cfg.seed);
    % golden.foo_checksum = ...;
else
    golden.foo_checksum = [];
    warning('golden_harness:noToolbox', ...
        'Toolbox not found -- those entry points skipped.');
end

% -------------------------------------------------------------------------

if strcmp(mode, 'capture')
    save(golden_file, 'golden');
elseif strcmp(mode, 'replay')
    ref = load(golden_file, 'golden');
    assert(isequal(ref.golden, golden), 'golden_harness:mismatch', ...
        'golden output changed -- this edit is not behaviour-preserving');
else
    error('golden_harness:mode', 'mode must be ''capture'' or ''replay''');
end
end
